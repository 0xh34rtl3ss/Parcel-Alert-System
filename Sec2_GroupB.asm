# CAAL | Section 2 | Group B
# https://github.com/meran0/Parcel-Alert-System
# by Imran, Naqib, Taha, Ihsan.
.data
	Buffer: .space 256
	Parcel1: .space 256
	Parcel2: .space 256
	Parcel3: .space 256
	Parcel4: .space 256
	userBarcode: .space 11
	
	
	Userfile: .asciiz "C:/Users/SIRIUS/Desktop/CAAL/Project/UserData.txt"
	
	
	welcome: .asciiz "SIMULATION OF PARCEL HOME ALERT SYSTEM\n*****System Initialization*****"
	wrong_inputChar: .asciiz "\n[Error: Wrong input. make sure your character is either 'Y' or 'N']"
	doContinue: .asciiz "\n1)Owner availibility in the house(y/n): "  
	welcomeMessage: .asciiz "\n\n\n*******************************************\nHi! Welcome to Parcel Delivery Alert System\n"
	File_Error: .asciiz "\n[Error: cannot find and open the file. please check your file directory]"
	inHouse_msg: .asciiz           "        Owner is in the house :)\n"
	outHouse_msg: .asciiz          "       Owner is NOT in the house :(\n"
	promptMessage: .asciiz "Please enter the barcode: "
	nextLine: .asciiz "\n"
	barcodeExist_msg: .asciiz "Barcode is in the database\n"
	barcodeDNE_msg: .asciiz "Sorry, barcode is not in the database \n"
	received: .asciiz "\nPlease enter 'R' below upon receiving your parcel: "
	img_saved: .asciiz "img.jpeg"
	parcel_message: .asciiz "\nPlease display the parcel at the screen in the next 10 seconds. Thank You\n\n"
	camera_active: .asciiz "Camera will be activated in:\n"
	click: .asciiz "**click**\n\n"
	database_updated: .asciiz"\nDatabase has been updated."
	text_message: .asciiz "\nThe photo taken has been saved and a SMS will be sent to the parcel recepient as proof of delivery.\nThank You"
.text

#macro to print a text
.macro printText(%arg)
	li $v0,4
	la $a0,%arg
	syscall
.end_macro

#macro to read character
.macro readText(%addr,%num)
	li $v0,8
	la $a0,%addr
	li $a1,%num
	syscall	
.end_macro

#macro to initiate sleep()
.macro sleep(%arg)
	li $v0, 32
	la $a0, %arg
	syscall
.end_macro

#macro to playMIDI sound
.macro playMIDI(%pitch,%duration,%volume)
	la $v0, 33
	li $a0, %pitch #the pitch of the sound
	li $a1, %duration #the duration 
	li $a3, %volume #volume of the sound
	syscall
.end_macro

#macro to update databse [by saving img.jpeg into memery address of particular PArcel info]
.macro updateDatabase(%parcel)
	li $t1,0
	li $t2,64
	move $t3,%parcel
	add $t3,$t3,64 

	saveAgain:
	beq $t0,'\n',end
	lb, $t0,img_saved($t1)
	sb $t0,($t3)
	addi $t1,$t1,1
	addi $t3,$t3,1
	j saveAgain

	end:
	printText(database_updated)
.end_macro

#macro to exit/terminate program
.macro exitProgram()
	li $v0,10
	syscall
.end_macro

#macro to calculate the sum of barcode by get each byte/digit ,
#and add them until the last digit of the barcode
.macro getBarcodeSum(%addr,%reg)
	li $t0, 0 #counter to iterate address
	li $t1, 0 
	li $t2, 0 #register to load
	li %reg, 0 #register to save result
	li $t4, 0 #register tht save each byte read
	
getBytetoInt:
	la $t1,(%addr)
	li $t5,8
	addu $t1,$t1,$t0
	lb $t4, ($t1)
	andi $t2,$t4,0x0F # where $t2 contains the ascii digit . 
	sub $t5,$t5,$t0
	addi $t0,$t0,1
	jal timesTen
	add %reg,$t2,%reg
	blt $t0,8,getBytetoInt
	j end

timesTen:
	li $t6,10
	beq $t5,1,resume
	
	timesTenAgain:
	mult $t2,$t6
	mflo $t2
	subi $t5,$t5,1
	bne $t5,1,timesTenAgain
	beq $t5,1,resume

resume:
jr $ra

end:
#reset registers value
li $t0, 0 
li $t1, 0 
li $t2, 0 
li $t4, 0 
li $t5,0
li $t6,0
.end_macro


####################SYSTEM INITIALIZATION-start 
start:
		printText(nextLine)
		printText(welcome) #"SIMULATION OF PARCEL HOME ALERT SYSTEM\n*****System Initialization*****"
		printText(doContinue) #"\n1)Owner availibility in the house(y/n): "
		li $v0,12 #get the user input via syscall service no 12 (read character)
		syscall
		j ValidateYesNo 

continuetoReadBarcode: 

move $s7,$v0
j Readfile

		#procedure to validate user input (Y/N)
		ValidateYesNo: #validate if its N or n or anything else
			beq $v0,'n',continuetoReadBarcode #if input == 'n' => exit program (on line 67 )
			beq $v0,'N',continuetoReadBarcode #if input == 'N' => exit program (on line 67 )
			beq $v0,'y',continuetoReadBarcode #if input == 'Y' => exit validate , jr to last PC to continue looping back through 'do'
			beq $v0,'Y',continuetoReadBarcode #if input == 'Y' => exit validate , jr to last PC to continue looping back through 'do'

			j AskAgain #if input neither 'n/N' nor 'y/Y' , ask the user to enter the acceptable character

AskAgain:
	printText(wrong_inputChar)#"\nWrong input,make sure your character is either 'Y' or 'N'"
	printText(nextLine)
	printText(doContinue)
	li $v0,12
	syscall
	j ValidateYesNo
####################SYSTEM INITIALIZATION-end

####################FILE OPEN AND READ-start	
fileError:
   printText(File_Error)
   exitProgram()
   

Readfile:
	#open file
	li $v0,13
	la $a0,Userfile #full directory of the file
	li $a1, 0 #mode 0->for read-only
	li $t4,0 #counter for reading file
	syscall
	
	beq $v0,-1,fileError
	
	move $s0,$v0 
	li $s3,0
	la $s1,Parcel1
	subi $t1,$s1,1

ReadLine:
	beq $s4,10,DoThiss #when meet '\n'
	bgt $t4,3,closeFile #since we only have four data in the txt

	li $v0,14 #read file
	move $a0,$s0
	la $a1, Buffer
	la $a2, 1
	syscall

	lb $s4, Buffer #get byte tht has been read into register
	add $t1,$t1,1
	sb $s4, ($t1) #store in the memory
	# increment line length
	addi $s3,$s3 1

	b ReadLine

DoThiss:
	addi $t4,$t4,1
	li $s4,0 #reset $s4
	li $t8,256
	mult $t4,$t8 #go to the next 256 byte -> address of Parcel2 
	mflo $t2

	add $t1,$s1,$t2
	subi $t1,$t1,1
b ReadLine

closeFile:
	#close file syscall service
	li $v0,16
	move $a0,$s0
	syscall
	
	j readBarcode
####################FILE OPEN AND READ-end

####################BARCODE READING -start
printInHome:
	
	beq $s7,'Y',inHouse
	beq $s7,'y',inHouse
	beq $s7,'N',outHouse
	beq $s7,'n',outHouse
	
	inHouse:
	printText(inHouse_msg)
	j donePrint
	
	outHouse:
	printText(outHouse_msg)
	j donePrint

donePrint:
jr $ra



readBarcode:
    # Display welcome message
    printText(welcomeMessage)
    jal printInHome
    

main:
    # Prompt to enter barcode
    printText(promptMessage)
    readText(userBarcode,9)
    printText(nextLine)
    
    li $t0,0 #counter
    
    loop_here:
    la $t1,userBarcode #load address of the user barcode
    add $t1,$t1,$t0
    # Load first byte of user input
    lb $t2, ($t1)
    
    # Input validation
    jal check_for_char
    addi $t0,$t0,1
    blt $t0,8,loop_here
    
    j barcodeValidationWithDB
    
    check_for_char:
    	bge $t2, 58, main
    	blt $t2,48,main
    	beq $t0, 0, check_zero
    	beq $t0, 7, check_zero
    	jr $ra
    	check_zero:
    	beq $t2,48,main
    	jr $ra
  
####################BARCODE READING -end


####################BARCODE VALIDATION -start
barcodeDNE:
	printText(barcodeDNE_msg)
	j readBarcode
barcodeExist:
	#save the address of the found parcel in register $s5
	subi $s5,$s5,1
	mult $s5,$t8
	mflo $s5
	la $s0, Parcel1
	add $s5,$s5,$s0
	
	printText(barcodeExist_msg)
	j Check_availability
	
barcodeValidationWithDB:
	
	li $s5,0 #counter
	li $s2,256 #increment by 256

	
	la $s0,userBarcode
	getBarcodeSum($s0,$s3)
	
	findNext:
		beq $s5,4,barcodeDNE
		mul $s1,$s5,$s2 
		mflo $s1
		la $s0,Parcel1 #load base address
		add $s0,$s0,$s1
		getBarcodeSum($s0,$s4)
	
		addi $s5,$s5,1
		bne $s3,$s4,findNext
		j barcodeExist
		
	

####################BARCODE VALIDATION -end

####################CHECK AVAILIBILITY OF OWNER -start
Check_availability:
	#printText(availability)
	beq $s7, 'y', Play_bell
	beq $s7, 'Y', Play_bell
	
	beq $s7, 'N',CameraActivation
	beq $s7, 'n',CameraActivation
####################CHECK AVAILIBILITY OF OWNER -end

####################IF THE OEWNER IS IN THE HOUSE ($s7='y'||'Y') -start
 Play_bell:
    #display parcel information
    li $v0,4
    move $a0,$s5
    syscall
    
    #play the ding sound (syscall 33)
    playMIDI(90,600,120)
    
    #play the dong sound (sycall 33)
    playMIDI(70,700,120)
    j Order_received

#label to ask the user to confirm that they have received the parcel
Order_received:
    	#timer (30 sec)  before prompting the received message
    	#to allow the user to answer the bell and collect the parcel
    	sleep(3000)#original=30000

askAgain:
    #Prompt to ask the user to enter 'R' upon receiving parcel
    printText(received)
    #get user input (character)
    li $v0, 12
    syscall
    
    #once the owner enters 'r' | 'R' (in device its a button)
    #branch into update label
    beq $v0, 'R', updateAndExit
    beq $v0, 'r', updateAndExit
    j askAgain

updateAndExit:
	updateDatabase($s5)
	exitProgram()
####################IF THE OEWNER IS IN THE HOUSE ($s7='y'||'Y') -end

####################IF THE OEWNER IS NOT IN THE HOUSE ($s7='n'||'N') -start
# Label to instruct the courier to left the parcel and camera will be activated 
#for a photo to be taken as proof of delivery  
CameraActivation:

    #display parcel information
    li $v0,4
    move $a0,$s5
    syscall
    
    # Store value '10' in register $s0 (act as a counter to decrement later)
    li $s0, 10
    # Display message
    printText(parcel_message)
    
    sleep(5000)# Delay (5 sec)
    printText(camera_active)# Display message indicating that the camera will be activated
    sleep(1500) # Delay (1.5 sec)

    
# Timer Label
loop:    
    # Exit loop when value in $s0 is less than 0
    blt $s0, 0, exit
    li $v0, 1
    move $a0, $s0
    syscall
    sleep(1000) # Delay (1 sec)
    printText(nextLine)
    
    # Decrement / Subtract contents in register $s0 with 1
    sub $s0, $s0, 1
    j loop
    
exit:
    printText(click)
    sleep(1500)# Delay (1.5 sec)
    printText(text_message) # Display message that the photo taken has been saved and an SMS will be sent to the owner as proof of delivery
    updateDatabase($s5)
    exitProgram()
    
####################IF THE OEWNER IS NOT IN THE HOUSE ($s7='n'||'N') -end
