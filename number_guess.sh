#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( RANDOM%1000 + 1 ))
COUNT=1

echo -e "\nEnter your username:"
read NAME

GAMES(){
  if [[ $COUNT == 1 ]]
  then
    echo -e "\nGuess the secret number between 1 and 1000:"
  fi
  read USER_INPUT
  if [[ $USER_INPUT =~ [^0-9] ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    GAMES
  fi
  if [[ $USER_INPUT == $NUMBER ]]
  then
    INTENT=$($PSQL "SELECT best_game FROM users WHERE user_name = '$NAME'")
    if [[ $INTENT == 0 || $INTENT -gt $COUNT  ]]
    then
      INTENT=$COUNT
    fi
    ($PSQL"UPDATE users SET games_played=(games_played + 1), best_game=$INTENT WHERE user_name='$NAME'")
    echo -e "\nYou guessed it in $COUNT tries. The secret number was $NUMBER. Nice job!"
    exit
  elif [[ $USER_INPUT -lt $NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
    COUNT=$((COUNT + 1))
    GAMES
  else
    echo -e "\nIt's lower than that, guess again:"
    COUNT=$((COUNT + 1))
    GAMES
  fi
}


if [[ $NAME ]]
  then
  DATA_USER=$($PSQL "SELECT * FROM users WHERE user_name = '$NAME'")
  if [[ -z $DATA_USER ]]
  then
    echo "Welcome, $NAME! It looks like this is your first time here."
    ($PSQL "INSERT INTO users(user_name, games_played, best_game) VALUES('$NAME', 0, 0)")
    GAMES $NAME
  else
    echo "$DATA_USER" | while IFS='|' read USER_NAME GAMES_PLAYED BEST_GAME
    do
      echo -e "\nWelcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses." 
    done
    GAMES $NAME 
  fi
fi

