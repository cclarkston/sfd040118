global class ScheduleLeadershipReport {
  global void StockPriceJobScheduler() {}
  public static void start() {
    //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    System.schedule('LeaderShip Reports Email', '0 0 7 ? * 2-6', new SendLeadershipReports());
    //System.schedule('Monthly Snapshot', '0 45 13 20 4 ?', new Take_Monthly_Snapshot());
   // System.schedule('Monthly Revenue Breakout', '0 0 6 1 * ?', new SendCenterYearlyNumbers());
  }
}