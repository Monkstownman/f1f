/**
 * Created by johncog on 03/09/16.
 */
function email_measuresJAC() {

    var name_spreadsheet = "fire1foundry";

    users_to_cycle_through = 2;
    for (var z = 0; z < users_to_cycle_through; z++) {

        var range_number = (parseInt(z) * 5 + 7).toString();
        var user = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("fire1foundry").getRange("A" + range_number).getValue();

        measures_to_cycle_through = 4;
        for (var k = 0; k < measures_to_cycle_through; k++) {
            var number_days_in_series = 18;
            var number_days_data = 1;
            var range_number = (parseInt(z) * 5 + parseInt(k) + 7).toString();
            var range = "B" + range_number;
            Logger.log('range "%s".', range);
            var measure_name = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("fire1foundry").getRange(range).getValue();
            var source = user + "_virtual_device";

            for (var j = 0; j < number_days_in_series; j++) {
                Logger.log('j number of days at start "%s".', j);

                var date = new Date();
                var time = new Date(new Date().setDate(date.getDate() - j));
                var cell_letter = "";
                var next_cell_letter = "";

                /**
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

                 Logger.log('cell_letter "%s".', cell_letter );
                 Logger.log('cache_first_value "%s".', cache_first_value );




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

                 */

                //MailApp.sendEmail("johnacogan@gmail.com", subject, "");
                //Logger.log('subject "%s".', subject);

                //SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name_spreadsheet).getRange(cell_letter + range_number).setValue(SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name_spreadsheet).getRange(next_cell_letter + range_number).getValue());

                // if (j == number_days_to_cycle_through - 1) {
                //     SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name_spreadsheet).getRange(cell_letter + range_number).setValue(cache_first_value);
                // }
                Logger.log('j number of days at end "%s".', j);
            }
        }
    }
}