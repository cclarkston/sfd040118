global class Take_Ranking_Snapshot implements Schedulable {
  //System.schedule('Daily Ranking', '0 0 20 ? * *', new Take_Ranking_Snapshot());
  global void execute(SchedulableContext ctx) {
  	run_pec_ranking_snapshot.take_ranking_snapshot();
  }
}