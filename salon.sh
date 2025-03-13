#!/bin/bash

# Conexión a la base de datos
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Función para mostrar servicios disponibles
DISPLAY_SERVICES() {
  echo -e "\nAvailable services:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Función para agendar cita
SCHEDULE_APPOINTMENT() {
  echo -e "\nEnter the service ID you want:"
  read SERVICE_ID_SELECTED

  # Validar que el servicio exista
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nInvalid service. Please choose again."
    DISPLAY_SERVICES
    SCHEDULE_APPOINTMENT
  else
    echo -e "\nEnter your phone number:"
    read CUSTOMER_PHONE

    # Buscar cliente en la base de datos
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]; then
      echo -e "\nNew customer! Please enter your name:"
      read CUSTOMER_NAME
      $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    echo -e "\nEnter the time for your appointment:"
    read SERVICE_TIME

    # Agregar cita
    $PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# Ejecutar script
DISPLAY_SERVICES
SCHEDULE_APPOINTMENT
