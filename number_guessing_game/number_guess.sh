#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#GENERATING RANDOM NUMBER
RANDOM_NUMBER=$(( (RANDOM % 1000) + 1 ))

echo "Enter your username:"
read USERNAME
echo $USERNAME

PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")

if [[ -z $PLAYER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE player_id=$PLAYER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE player_id=$PLAYER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#read user initial input (round 1)
ROUND_PLAYED=1
#ROUND_PLAYED=$(( ROUND_PLAYED + 1 ))
echo "Guess the secret number between 1 and 1000:"
read PLAYER_GUESS
while [[ ! $PLAYER_GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read PLAYER_GUESS
done

while (( PLAYER_GUESS != RANDOM_NUMBER )) 
do
  if (( PLAYER_GUESS > RANDOM_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read PLAYER_GUESS
  ROUND_PLAYED=$(( ROUND_PLAYED + 1 ))
  while [[ ! $PLAYER_GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read PLAYER_GUESS
  done
done

#UPDATE DATABASE
if [[ -z $PLAYER_ID ]]
then
  INSERT_PLAYER_RESULT=$($PSQL "INSERT INTO players(username, games_played, best_game) VALUES('$USERNAME', 1, $ROUND_PLAYED)")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE player_id=$PLAYER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE player_id=$PLAYER_ID")
  GAMES_PLAYED=$(( GAME_PLAYED + 1 ))
  BEST_GAME=$(( BEST_GAME < ROUND_PLAYED ? BEST_GAME : ROUND_PLAYED ))
  UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE players SET games_played = $GAMES_PLAYED WHERE player_id=$PLAYER_ID")
  UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE players SET best_game = $BEST_GAME where player_id=$PLAYER_ID")
fi

echo "You guessed it in $ROUND_PLAYED tries. The secret number was $RANDOM_NUMBER. Nice job!"
exit