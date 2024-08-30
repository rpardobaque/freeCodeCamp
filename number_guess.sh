#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number between 1 and 1000
SECRET_NUMBER=$((RANDOM % 1000 + 1))

# Prompt for the username
echo "Enter your username:"
read USERNAME
#DSAF KJ
# Check if the user exists in the database
USER_DATA=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  echo "$USER_DATA" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# Prompt for number guessing
echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0
#
while true
do
  read GUESS
  ((NUMBER_OF_GUESSES++))

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    if [[ -z $USER_DATA ]]
    then
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = 1, best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME'")
    else
      echo "$USER_DATA" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME
      do
        NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))

        if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME || $BEST_GAME -eq 0 ]]
        then
          BEST_GAME_UPDATE=$NUMBER_OF_GUESSES
        else
          BEST_GAME_UPDATE=$BEST_GAME
        fi

        UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $NEW_GAMES_PLAYED, best_game = $BEST_GAME_UPDATE WHERE username='$USERNAME'")
      done
    fi
    break
  fi
done

