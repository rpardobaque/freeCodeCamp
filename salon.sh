#! /bin/bash

# Define the command to interact with the database
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Function to display the list of services
display_services() {
  echo -e "\nWelcome to the Salon! How can I help you today?\n"
  
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Function to prompt for service ID
prompt_for_service_id() {
  read SERVICE_ID_SELECTED
  
  # Check if the selected service ID is valid
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  # If the service ID is not valid, display the list again
  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nI could not find that service. Please choose a valid service."
    display_services
    prompt_for_service_id
  fi
}

# Display the list of services
display_services

# Prompt the user to select a service
echo -e "\nPlease select a service by entering the corresponding number:"
prompt_for_service_id

# Continue with the rest of the script after a valid service ID is selected
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  
  # Insert the new customer into the database
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
