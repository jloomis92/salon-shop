#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~ Salon Services ~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Please select the service you wish to book:"
  echo -e "\n1) Haircut\n2) Cut and Wash\n3) Cut and Shave\n4) Cut and Color"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
  1|2|3|4) BOOKING_MENU ;;
  5) EXIT ;;
  *) MAIN_MENU "Please enter a valid service number." ;;
  esac
}

BOOKING_MENU() {
  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # ask for appointment time
  echo -e "\nWhat time would you like to set for your appointment?"
  read SERVICE_TIME
  # insert appointment and time
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  
  # get service name, then display confirmation to customer
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  else
    echo -e "\nI've run into some sort of issue..."
  fi
}

EXIT() {
  echo -e "\nThank you for stopping in today!\n"
}

MAIN_MENU