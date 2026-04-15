/// Visual states for [AllClientCard].
///
/// Three mutually exclusive states — enum prevents invalid bool combinations.
/// [add] shows the "+" action; [rosterFull] hides the right zone entirely;
/// [remove] shows the "×" action.
enum AllClientCardState { add, rosterFull, remove }
