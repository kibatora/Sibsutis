#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_DESTINATION_LENGTH 50
#define MAX_FLIGHT_NUMBER_LENGTH 10
#define MAX_AIRCRAFT_TYPE_LENGTH 20

typedef struct {
    char destination[MAX_DESTINATION_LENGTH];
    char flight_number[MAX_FLIGHT_NUMBER_LENGTH];
    char aircraft_type[MAX_AIRCRAFT_TYPE_LENGTH];
} FlightRecord;

void addRecordToFile(FILE *file) {
    FlightRecord record;

    printf("Enter destination: ");
    fgets(record.destination, MAX_DESTINATION_LENGTH, stdin);
    record.destination[strcspn(record.destination, "\n")] = '\0'; // remove \n from fgets

    printf("Enter flight number: ");
    fgets(record.flight_number, MAX_FLIGHT_NUMBER_LENGTH, stdin);
    record.flight_number[strcspn(record.flight_number, "\n")] = '\0'; // remove \n from fgets

    printf("Enter aircraft type: ");
    fgets(record.aircraft_type, MAX_AIRCRAFT_TYPE_LENGTH, stdin);
    record.aircraft_type[strcspn(record.aircraft_type, "\n")] = '\0'; // remove \n from fgets

    fwrite(&record, sizeof(FlightRecord), 1, file);
    printf("Record added to file.\n");
}

void searchFlightRecordsByAircraftType(FILE *file) {
    char aircraftType[MAX_AIRCRAFT_TYPE_LENGTH];
    int found = 0;

    printf("Enter aircraft type: ");
    fgets(aircraftType, MAX_AIRCRAFT_TYPE_LENGTH, stdin);
    aircraftType[strcspn(aircraftType, "\n")] = '\0'; // remove \n from fgets

    FlightRecord record;
    rewind(file); // move cursor to the beginning of the file
    while (fread(&record, sizeof(FlightRecord), 1, file) == 1) {
        if (strcmp(record.aircraft_type, aircraftType) == 0) {
            printf("Destination: %s\nFlight number: %s\n", 
                   record.destination, record.flight_number);
            found = 1;
        }
    }

    if (!found) {
        printf("No flight records found for aircraft type %s.\n", aircraftType);
    }
}

int main() {
    FILE *file;
    char filename[50];
    int operation;

    do {
        printf("Choose operation:\n1. Add record to file\n2. Search flight records by aircraft type\n3. Exit\n");
        scanf("%d", &operation);
        getchar(); // remove \n from scanf buffer

        if (operation == 1) {
            printf("Enter filename: ");
            fgets(filename, 50, stdin);
            filename[strcspn(filename, "\n")] = '\0'; // remove \n from fgets

            file = fopen(filename, "ab");
            if (file == NULL) {
                printf("Error opening file.\n");
                exit(1);
            }

            addRecordToFile(file);
            fclose(file);
        } else if (operation == 2) {
            printf("Enter filename: ");
            fgets(filename, 50, stdin);
            filename[strcspn(filename, "\n")] = '\0'; // remove \n from fgets

            file = fopen(filename, "rb");
            if (file == NULL) {
                char choice;
                printf("File does not exist. Do you want to create a new file? (Y/N)\n");
                scanf(" %c", &choice);
                getchar(); // remove \n from scanf buffer
                if (choice == 'Y' || choice == 'y') {
                    file = fopen(filename, "wb");
                    if (file == NULL) {
                        printf("Error creating file.\n");
                        exit(1);
                    }
                    printf("New file created.\n");
                    fclose(file);
                } else {
                    printf("Exiting program.\n");
                    exit(0);
                }
            } else {
                searchFlightRecordsByAircraftType(file);
                fclose(file);
            }
        }
    
    } while (operation != 3);

    return 0;
}