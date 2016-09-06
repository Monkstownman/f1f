/**
 * Created by johncog on 17/08/16.
 */
function doGet() {
    return ContentService.createTextOutput('Hello, world!');
}

var BATCH_SIZE = 50;
var ss = SpreadsheetApp.getActiveSpreadsheet();

//"measures":[{"name":"CPA"
// subject:("measures":[{"name":"CPA")  AND from: johnacogan@gmail.com

function printTasks() {
    var taskLists = Tasks.Tasklists.list();

    if (taskLists.items) {
        Logger.log('Number of tasklists "%s".', taskLists.items.length);

        for (var i = 0; i < taskLists.items.length; i++) {
            var taskList = taskLists.items[i];

            //Logger.log('Tasks name "%s".', taskList.title);
            var taskListId = taskList.id;
            var tasks = Tasks.Tasks.list(taskListId, {
                showHidden: true
            });

            if (tasks.items) {

                for (var j = 0; j < tasks.items.length; j++) {
                    var task = tasks.items[j];
                    Logger.log('"%s"', task.notes);
                }
            }
        }
    }
}

function updateDashboardJAC() {
    var days = 5
    var beforeOneWeek = new Date(new Date().getTime() - 60 * 60 * 24 * days * 1000);
    var formattedDate = Utilities.formatDate(beforeOneWeek, "GMT", "yyyy/MM/dd");
    Logger.log('formattedDate "%s".', formattedDate);

    //init_();
    var sheetNumber = 1;
    var query = "from:action@ifttt.com AND after:" + formattedDate;
    graphMeasureJAC(sheetNumber, query);

    var sheetNumber = 2;
    var query = "subject:Daily AND after:" + formattedDate;
    graphMeasureJAC(sheetNumber, query);

    var sheetNumber = 3;
    var query = "subject:CRR AND after:" + formattedDate;
    graphMeasureJAC(sheetNumber, query);

    var sheetNumber = 4;
    var query = "subject:CPA AND after:" + formattedDate;
    graphMeasureJAC(sheetNumber, query);

    var sheetNumber = 5;
    var query = "subject:Ulster AND after:" + formattedDate;
    graphMeasureJAC(sheetNumber, query);
}

function graphMeasureJAC(sheetNumber, query) {
    // VG: Search Gmail with filter Criteria. Result is in forms of conversations (grouped messages)
    var conservations = GmailApp.search(query);
    // Get all the sheets
    var sheets = ss.getSheets();
    var record = [];
    var previousRecordTime = new Date();
    for (var i = 0; i < conservations.length; i++) {
        var conversationId = conservations[i].getId();
        var firstMessageSubject = conservations[i].getFirstMessageSubject();
        //VG: Drill down the conversation. Get the messages in conversations.
        var messages = conservations[i].getMessages();
        var nbrOfMessages = messages.length;
        // VG: Going through all the messages in the conversation.
        for (var j = 0; j < nbrOfMessages; j++) {
            var process = true;
            //VG: Process the message
            if (process) {
                Utilities.sleep(1000);
                // VG: convert the date and time of the message to userTimeZone
                var subject = messages[j].getSubject();

                if (subject.indexOf("Watch") >= 0) {
                    var body = messages[j].getBody();
                    subject = convertWeightJSONJAC(body);
                }

                if (subject.indexOf("Ulster") >= 0) {
                    var body = messages[j].getBody();
                    subject = convertBankBalanceJointAccountJSONJAC(body);
                }

                if (subject.indexOf("measure") >= 0) {
                    var obj = JSON.parse(subject);
                    var name = obj.measures[0].name;
                    var value = obj.measures[0].value;
                    var time = obj.measures[0].time.substring(0, 24);
                    var unit = obj.measures[0].unit
                }

                if (time == previousRecordTime) {
                    // Do nothing
                } else {
                    record.push([time, value]);
                }
                previousRecordTime = time;
            }
        }
    }
    if (sheets[sheetNumber] == undefined) {
        ss.insertSheet();
    }
    SpreadsheetApp.flush();
    sheets = ss.getSheets();
    lastColumn = sheets[sheetNumber].getMaxColumns();
    if (lastColumn > 2) {
        sheets[sheetNumber].deleteColumns(2, lastColumn - 2);
    }
    sheets[sheetNumber].clear().getRange("A1:B1").setValues([
        ["Time", name + " (" + unit + ")"]
    ]);
    sheets[sheetNumber].getRange("A2:A").setNumberFormat("yyyy-mm-dd HH:mm");
    sheets[sheetNumber].setName(name);
    SpreadsheetApp.flush();
    Logger.log('name "%s".', name);
    Logger.log('time "%s".', time);
    Logger.log('previousRecordTime "%s".', previousRecordTime);
    if (record[0] != undefined && sheets[sheetNumber].getMaxRows() < 38000) sheets[sheetNumber].getRange(sheets[sheetNumber].getLastRow() + 1, 1, record.length, record[0].length).setValues(record);
}

function emailFitMeasuresJAC() {
    var taskLists = Tasks.Tasklists.list();
}

function convertBankBalanceJointAccountJSONJAC(body) {
    var res = body.split(" ");
    var value = res[5].substring(1, res[5].length - 3);
    var startDateTimeStr = body.search("Received: ");
    var endDateTimeStr = body.search(" GMT");
    var time = body.substring(startDateTimeStr + 10, endDateTimeStr + 15);
    var unit = "euro";
    var subject = JSON.stringify({
        "measures": [{
            "name": "Bank Balance Joint Account",
            "time": time,
            "value": value,
            "unit": unit,
            "source": "",
            "user": ""
        }]
    });
    return subject;
}

function emailBankBalanceJointAccountJAC() {
    query = "Available subject:Ulster AND subject:Relay AND is:unread"

    // VG: Search Gmail with filter Criteria. Result is in forms of conversations (grouped messages)
    var conservations = GmailApp.search(query);
    for (var i = 0; i < conservations.length; i++) {
        var conversationId = conservations[i].getId();
        var firstMessageSubject = conservations[i].getFirstMessageSubject();
        //VG: Drill down the conversation. Get the messages in conversations.
        var messages = conservations[i].getMessages();
        var nbrOfMessages = messages.length;
        // VG: Going through all the messages in the conversation.
        for (var j = 0; j < nbrOfMessages; j++) {
            var process = true;
            //VG: Process the message
            if (process) {
                Utilities.sleep(1000);

                // JAC: Mark message at read or remore label unread
                messages[j].markRead()
                var subject = messages[j].getSubject();
                var body = messages[j].getBody();
                subject = convertBankBalanceJointAccountJSONJAC(body);
                MailApp.sendEmail("johnacogan@gmail.com", subject, "");
                Logger.log('Number of completed tasks is "%s".', subject);
            }
        }
    }
}

function emailRandomFire1FoundryMeasureJAC() {
    var date = new Date();
    var date = date.setDate(date.getDate() - 1);
    var time = new Date(date);
    var value = Math.random().toString();
    var subject = JSON.stringify({
        "measures": [{
            "name": "F1F",
            "time": time,
            "value": value,
            "unit": "f1f",
            "source": "random",
            "user": "johnacogan@gmail.com"
        }]
    });
    Logger.log('Measure is "%s".', subject);
    // MailApp.sendEmail("johnacogan@gmail.com", subject, "");
}
/**
 * Created by johncog on 03/09/16.
 */
function email_measuresJAC() {
    var name_spreadsheet = "fire1foundry";

    users_to_cycle_through = 1;
    for (var z = 0; z < users_to_cycle_through; z++) {
        var range_number = (parseInt(z) * 5 + 7).toString();
        var user = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("fire1foundry").getRange("A" + range_number).getValue();

        measures_to_cycle_through = 2;
        for (var k = 0; k < measures_to_cycle_through; k++) {
            var number_days_in_series = 18;
            var number_days_data = 18;

            for (var w = 0; w < number_days_data; w++) {
                var range_number = (parseInt(z) * 5 + parseInt(k) + 7).toString();
                var range = "B" + range_number;
                //Logger.log('range "%s".', range);
                var measure_name = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("fire1foundry").getRange(range).getValue();
                var source = user + "_virtual_device";
                var date = new Date();
                var time = new Date(new Date().setDate(date.getDate() - w));

                for (var j = 0; j < number_days_in_series; j++) {
                    //  Logger.log('j number of days at start "%s".', j);
                    var cell_letter = "";
                    var next_cell_letter = "";

                    switch (j) {
                        case 0:
                            cell_letter = "C";
                            next_cell_letter = "D";
                            var cache_first_value = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name_spreadsheet).getRange(cell_letter + range_number).getValue();
                            break;

                        case 1:
                            cell_letter = "D";
                            next_cell_letter = "E";
                            break;
                        case 2:
                            cell_letter = "E";
                            next_cell_letter = "F";
                            break;
                        case 3:
                            cell_letter = "F";
                            next_cell_letter = "G";
                            break;
                        case 4:
                            cell_letter = "G";
                            next_cell_letter = "H";
                            break;
                        case 5:
                            cell_letter = "H";
                            next_cell_letter = "I";
                            break;
                        case 6:
                            cell_letter = "I";
                            next_cell_letter = "J";
                            break;
                        case 7:
                            cell_letter = "J";
                            next_cell_letter = "K";
                            break;
                        case 8:
                            cell_letter = "K"
                            next_cell_letter = "L"
                            break;
                        case 9:
                            cell_letter = "L";
                            next_cell_letter = "M";
                            break;
                        case 10:
                            cell_letter = "M";
                            next_cell_letter = "N";
                            break;
                        case 11:
                            cell_letter = "N";
                            next_cell_letter = "O";
                            break;
                        case 12:
                            cell_letter = "O";
                            next_cell_letter = "P";
                            break;
                        case 13:
                            cell_letter = "P";
                            next_cell_letter = "Q";
                            break;
                        case 14:
                            cell_letter = "Q";
                            next_cell_letter = "R";
                            break;
                        case 15:
                            cell_letter = "R";
                            next_cell_letter = "S";
                            break;
                        case 16:
                            cell_letter = "S";
                            next_cell_letter = "T";
                            break;
                        case 17:
                            cell_letter = "T";
                            next_cell_letter = "U";
                            break;
                        case 18:
                            cell_letter = "U";
                            next_cell_letter = "V";
                            break;
                    }

                    //   Logger.log('cell_letter "%s".', cell_letter );
                    //    Logger.log('cache_first_value "%s".', cache_first_value );
                    SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name_spreadsheet).getRange(cell_letter + range_number).setValue(SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name_spreadsheet).getRange(next_cell_letter + range_number).getValue());

                    if (j == number_days_in_series - 1) {
                        SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name_spreadsheet).getRange(cell_letter + range_number).setValue(cache_first_value);
                    }
                    // Logger.log('j number of days at end "%s".', j);
                }

                var subject = JSON.stringify({
                    "measures": [{
                        "name": measure_name,
                        "time": time,
                        "value": SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name_spreadsheet).getRange(cell_letter + range_number).getValue().toString(),
                        "unit": "mm",
                        "source": source,
                        "user": user
                    }]
                });

                //MailApp.sendEmail("johnacogan@gmail.com", subject, "");
                Logger.log('subject "%s".', subject);
            }
        }
    }
}