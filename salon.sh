#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

show_menu() {
  service_rows=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$service_rows" | while read id sep label
  do
    echo "$id) $label"
  done

  read chosen_id
  chosen_service=$($PSQL "SELECT name FROM services WHERE service_id=$chosen_id")

  if [[ -z $chosen_service ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    show_menu
  else
    echo -e "\nWhat's your phone number?"
    read phone_input

    client_name=$($PSQL "SELECT name FROM customers WHERE phone='$phone_input'")

    if [[ -z $client_name ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read client_name
      add_client=$($PSQL "INSERT INTO customers(name, phone) VALUES('$client_name', '$phone_input')")
    fi

    client_id=$($PSQL "SELECT customer_id FROM customers WHERE phone='$phone_input'")
    service_clean=$(echo $chosen_service | sed -e 's/^ *//g')
    name_clean=$(echo $client_name | sed -e 's/^ *//g')

    echo -e "\nWhat time would you like your $service_clean, $name_clean?"
    read appointment_slot

    add_appointment=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($client_id, $chosen_id, '$appointment_slot')")

    echo -e "\nI have put you down for a $service_clean at $appointment_slot, $name_clean."
  fi
}

show_menu
