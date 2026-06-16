enum LudoGameState {
  needRoll,    // Player needs to roll dice
  rolling,     // Dice is rolling animation
  needMove,    // Player needs to select a token to move
  moving,      // Token is moving animation
  resolving,   // Resolving checks (e.g. collision, next player turn)
  gameOver,    // Game completed
}
