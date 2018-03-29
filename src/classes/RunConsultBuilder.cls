global class RunConsultBuilder implements Schedulable {
  global void execute(SchedulableContext ctx) {
    Consult_Inventory_Builder.build_room_inventory();
  }
}