#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Set the input file
file="games.csv"
Y=0
R=1
WIN=2
OPP=3
WIN_GOAL=4
OPP_GOAL=5

while read line; do
  IFS=',' read -ra fields <<< "$line"

  if [ ${fields[0]} != "year" ]; then

    # add winner teams to database (if doesn't exist)
    if [[ -z $($PSQL "SELECT name FROM teams WHERE name='${fields[$WIN]}' LIMIT 1;") ]]; then
      $PSQL "INSERT INTO teams(name) VALUES('${fields[$WIN]}');"
    fi

    # add opponent teams to database (if doesn't exist)
    if [[ -z $($PSQL "SELECT name FROM teams WHERE name='${fields[$OPP]}' LIMIT 1;") ]]; then
      $PSQL "INSERT INTO teams(name) VALUES('${fields[$OPP]}');"
    fi

    # add game to database
    win_id=$($PSQL "SELECT team_id FROM teams WHERE name='${fields[$WIN]}';")
    opp_id=$($PSQL "SELECT team_id FROM teams WHERE name='${fields[$OPP]}';")
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES(${fields[$Y]}, '${fields[$R]}', $win_id, $opp_id, ${fields[$WIN_GOAL]}, ${fields[$OPP_GOAL]});"
  fi

done < "$file"
