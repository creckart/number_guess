#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

# Generate random number
SECRET_NUMBER=$(( 1 + $RANDOM % 1000 ))

# get username and stats
echo "Enter your username:"
read USERNAME
CURRENT_USER=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $CURRENT_USER ]]
then
  # if no username
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # if username, print stats
  read GAMES_PLAYED BAR BEST_GAME <<< $CURRENT_USER
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
while [[ -z $USER_GUESS || $USER_GUESS != $SECRET_NUMBER ]]
do
  read USER_GUESS
  if [[ ! -z $USER_GUESS ]]
  then
    GUESS_COUNT=$((GUESS_COUNT+1))
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    elif (( $USER_GUESS > $SECRET_NUMBER ))
    then
      echo "It's lower than that, guess again:"
    elif (( $USER_GUESS < $SECRET_NUMBER ))
    then
      echo "It's higher than that, guess again:"
    fi
  fi
done

echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

# if new user
if [[ -z $CURRENT_USER ]]
then
  # create stats row
  USER_STATS=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $GUESS_COUNT)")
elif (( $GUESS_COUNT > $BEST_GAME ))
then
  # update best_game
  USER_STATS=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")
else
  # update best_game and guess_count
  USER_STATS=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = $GUESS_COUNT WHERE username='$USERNAME'")
fi
