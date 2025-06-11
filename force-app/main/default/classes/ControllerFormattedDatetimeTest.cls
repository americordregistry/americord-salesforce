@isTest
public  class ControllerFormattedDatetimeTest {
static testMethod void test() {


  ControllerFormattedDatetime cond = new ControllerFormattedDatetime();
  cond.date_time = null;
  String defined_format = cond.defined_format;
  cond.selected_timezone = 'EST';
  String getFormattedDatetime = cond.getFormattedDatetime();
 
  ControllerFormattedDatetime cond2 = new ControllerFormattedDatetime();
  cond2.date_time = date.newInstance(2012, 9, 22);
  cond2.selected_timezone = 'EST';
  String defined_format2 = cond2.defined_format;
  String getFormattedDatetime2 = cond2.getFormattedDatetime();
 
  }
}