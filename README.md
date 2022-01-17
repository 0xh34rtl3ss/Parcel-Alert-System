# Simulation of Parcel Alert System 
### _CAAL | Section 2 | Group B_



## Group Members
- Muhammad Imran bin Mohamad (1912837)
- Muhammad Naqib Syahmi bin Ab Razak (1910147)
- Soomro Taha Ali (1918967)
- Muhammad Ihsan bin Ahmad Hanizar (1919939)

## Disclaimer

- This is only a simulation and a working proof of concept for our project title 'Parcel delivery
alert'.
- This system and the devices are meant to be implement/install in the US neighborhood area.
- For the purpose of simulation, this program strictly only read 4 barcode values from the file separated by '\n'.
- No SMS are sent during this simulation
- "Camera click" is to simulate the camera is taking a photo.

## Features
- File as input stream (reading from txt file. to simulate implementation of API request from e-commerce platform eg: get user orders that contains parcel barcode number, recipient name, and courier etc. from Shopee API and store the info locally in the program )
- Use macro to simplify the source code and reduce redundancy 
- Barcode validation (to make sure that the user input is in the correct format as the barcode in the memory eg: no characters, no '0' at the front or at the end)
- User input validation for every user input
- Error handling (tell user the error and how to solve that error) eg: file cannot be open, change directory
- Audio output ( using syscall 33 to output an audio via MIDI )

## Program Flowchart
![alt text](https://i.ibb.co/9v0Sqs7/program-flow-drawio-1.png)


## Demo
[![N|Solid](https://images.squarespace-cdn.com/content/v1/5f3a60f80638305e031c31bd/1631161685918-FVHK4FVDGGVZVZEV47XO/youtube+logo.png)](https://www.youtube.com/watch?v=6o1JeI5yXxI)

## Installation
1) Clone this repo 
2) Open the .asm file via MARS
3) Edit the directory in the "Userfile" data section with your path to "UserData.txt"
Example:
```assembly
Userfile: .asciiz "C:/Users/SIRIUS/Desktop/CAAL/Project/UserData.txt"
```
4) Save, assemble and run the code.

