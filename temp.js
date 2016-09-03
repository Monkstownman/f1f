/**
 * Created by johncog on 03/09/16.
 */
function email_measuresAC() {
    number_days_to_cycle_through = 1;

    for (i = 0; i < number_days_to_cycle_through; i++) {
        var date = new Date();
        var time = new Date(new Date().setDate(date.getDate() - i));
        var user = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("fire1foundry").getRange("A7").getValue();
        var source = user + "_virtual_device";
        var number_days_data = 3;
        var name_spreadsheet = "fire1foundry";
        var measure_name = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("fire1foundry").getRange("B7").getValue();

        for (j = 0; j < number_days_data; j++) {

            if (j = 0) {
                cell_letter = "C";
                next_cell_letter = "D";
            } else if (j = 1) {
                cell_letter = "D";
                next_cell_letter = "E";
            } else if (j = 2) {
                cell_letter = "E";
                next_cell_letter = "F";
            } else if (j = 3) {
                cell_letter = "F";
                next_cell_letter = "G";
            } else if (j = 4) {
                cell_letter = "G";
                next_cell_letter = "H";
            } else if (j = 5) {
                cell_letter = "H";
                next_cell_letter = "I";
            } else if (j = 6) {
                cell_letter = "I";
                next_cell_letter = "J";
            } else if (j = 7) {
                cell_letter = "J";
                next_cell_letter = "K";
            } else if (j = 8) {
                cell_letter = "K"
                next_cell_letter = "L"
            } else if (j = 9) {
                cell_letter = "L";
                next_cell_letter = "M";
            } else if (j = 10) {
                cell_letter = "M";
                next_cell_letter = "N";
            } else if (j = 11) {
                cell_letter = "N";
                next_cell_letter = "O";
            } else if (j = 12) {
                cell_letter = "O";
                next_cell_letter = "P";
            } else if (j = 13) {
                cell_letter = "P";
                next_cell_letter = "Q";
            } else if (j = 14) {
                cell_letter = "Q";
                next_cell_letter = "R";
            } else if (j = 15) {
                cell_letter = "R";
                next_cell_letter = "S";
            } else if (j = 16) {
                cell_letter = "S";
                next_cell_letter = "T";
            } else if (j = 17) {
                cell_letter = "T";
                next_cell_letter = "U";
            }

            else {
                cell_letter = "U";
                next_cell_letter = "V";
            }

            if (j = 0) {
                cache_first_value = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name_spreadsheet).getRange(cell_letter + "7").getValue();
            }

            var subject = JSON.stringify({
                "measures": [{
                    "name": measure_name,
                    "time": time,
                    "value": SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name_spreadsheet).getRange(cell_letter + "7").getValue(),
                    "unit": "mm",
                    "source": source,
                    "user": user
                }]
            });

            Logger.log('Measure is "%s".', subject);
            //MailApp.sendEmail("johnacogan@gmail.com", subject, "");
            SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name_spreadsheet).getRange(cell_letter + "7").setValue(SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name_spreadsheet).getRange(next_cell_letter + "7").getValue());

            if (j == number_days_data) {
                SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name_spreadsheet).getRange(next_cell_letter + "7").setValue(cache_first_value);
            }
        }
    }
}