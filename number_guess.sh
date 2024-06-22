#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Function to get user info or insert new user
get_user() {
  USERNAME=$1
  USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")
  
  if [[ -z $USER_INFO ]]; then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")
  fi

  IFS="|" read -r USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  
  if [[ -z $BEST_GAME ]]; then
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took no guesses yet."
  else
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

# Function to update user statistics
update_user_stats() {
  USER_ID=$1
  GUESSES=$2
  GAMES_PLAYED=$(($GAMES_PLAYED + 1))
  
  if [[ -z $BEST_GAME || $GUESSES -lt $BEST_GAME ]]; then
    BEST_GAME=$GUESSES
  fi
  
  UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE user_id=$USER_ID")
}

# Main game logic
main_game() {
  SECRET_NUMBER=$((RANDOM % 1000 + 1))
  GUESSES=0

  echo "Guess the secret number between 1 and 1000:"
  
  while true; do
    read GUESS
    
    if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
      continue
    fi
    
    GUESS=$((10#$GUESS))
    GUESSES=$((GUESSES + 1))
    
    if [[ $GUESS -lt $SECRET_NUMBER ]]; then
      echo "It's higher than that, guess again:"
    elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
      echo "It's lower than that, guess again:"
    else
      echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      update_user_stats $USER_ID $GUESSES
      break
    fi
  done
}

# Start the script
echo "Enter your username:"
read USERNAME

get_user $USERNAME
main_game
