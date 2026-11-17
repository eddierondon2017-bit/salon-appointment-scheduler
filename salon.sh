
#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

printf '\n~~~~~ MY SALON ~~~~~\n\n'
printf 'Welcome to My Salon, how can I help you?\n\n'

MAIN_MENU() {
  while true
  do
    SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

    echo "$SERVICES" | while IFS="|" read -r SERVICE_ID SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done

    read SERVICE_ID_SELECTED

    case "$SERVICE_ID_SELECTED" in
      ''|*[!0-9]*)
        SERVICE_NAME=""
        ;;
      *)
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        ;;
    esac

    if [ -n "$SERVICE_NAME" ]
    then
      break
    fi

    printf '\nI could not find that service. What would you like today?\n\n'
  done

  printf "\nWhat's your phone number?\n"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [ -z "$CUSTOMER_ID" ]
  then
    printf "\nI don't have a record for that phone number, what's your name?\n"
    read CUSTOMER_NAME

    $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" > /dev/null

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
  fi

  printf "\nWhat time would you like your %s, %s?\n" "$SERVICE_NAME" "$CUSTOMER_NAME"
  read SERVICE_TIME

  $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" > /dev/null

  printf "\nI have put you down for a %s at %s, %s.\n" "$SERVICE_NAME" "$SERVICE_TIME" "$CUSTOMER_NAME"
}

MAIN_MENU
