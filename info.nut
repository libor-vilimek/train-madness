class TrainMadness extends AIInfo {
  function GetAuthor()      { return "Libor Vilimek"; }
  function GetName()        { return "TrainMadness"; }
  function GetDescription() { return "AI capable of building huge train network."; }
  function GetVersion()     { return 1; }
  function GetDate()        { return "2023-09-07"; }
  function CreateInstance() { return "TrainMadness"; }
  function GetShortName()   { return "TMDS"; }
  function GetAPIVersion()  { return "1.9"; }
}

/* Tell the core we are an AI */
RegisterAI(TrainMadness());
