.data 
.align 2

input_buffer: 		.space 1024
			.align 2
			
input_buffer_clear: 	.space 1024
			.align 2

buffer_world: 		.space 100
			.align 2
		
buffer_search_world: 	.space 3
			.align 2
			
get_world_message:	.asciiz "\n Ingrese una palabra para buscar:\n "
			.align 2
			
world_init_message:	.asciiz "La palabra inicia en "
			.align 2

row_message:	 	.asciiz "\n fila: "
			.align 2
			
column_message: 		.asciiz "\n columna: "
			.align 2
			
not_found_message: 	.asciiz "\n No se encontró la palabra \n"
			.align 2

search_other_message: 	.asciiz "\n ¿Quieres buscar otra Palabra? s/n \n"
			.align 2
			
s:  			.asciiz "si"	
			.align 2
			
n: 			.asciiz "no"
			.align 2

finish_message: 	.asciiz "El programa finalizará \n"
			.align 2
			
options: 		.asciiz "\n Ingrese si para Continuar y no para Detener la ejecución \n"
			.align 2
			
separator:  		.asciiz " "
			.align 2
			
			
get_file_message: 	.asciiz "\n Ingresa el nombre del archivo: \n"
			.text


.text
Main:	
	jal read_file
	
#-------------------------------------------------------------------------------------------------------------
# FILE
#-------------------------------------------------------------------------------------------------------------
read_file:
	add $t1, $zero, $zero 						# Direccion del archivo
	add $t2, $zero, $zero 						# Direccion del archivo sin \n
	add $t3, $zero, $zero 						# Direccion de la ruta del archivo 
	add $t4, $zero, $zero 						# Dirección de la ruta del archivo sin \n
	add $t5, $zero, $zero 						# Bandera
	add $t6, $zero, $zero 						# Caracter leido del archivo

	li $v0, 4
	la $a0, get_file_message
	syscall

	li $v0, 8 	
	la $a0, input_buffer						# Dirección en memoria del archivo
    	li $a1, 1024							# Cantidad Max de caracteres de la ruta del archivo
    	syscall
	
	la $t1, input_buffer 						# se asigna en t1 la dirección en memoria del archivo
    	la $t2, input_buffer_clear 					# se asigna en t2 la dirección en memoria del archivo sin /n
  	add $t3, $t1, $zero 						# se clona t1
  	add $t4, $t2, $zero 						# se clona t2
	addi $t5, $t5, 10  						# indica final de la palabra
                     
clear_file:	 							# sirve para remover /n del archivo ingresado además de valida que el archivo no este vacio	
	lbu $t6, 0($t3)						
	beq $t6, $t5, validate_file 					
	sb $t6, 0($t4) 							
	addi $t3, $t3, 1 						
	addi $t4, $t4, 1 						
	j clear_file								
		
	
validate_file:								# validamos si el archivo existe			
	add $t3, $zero, $zero						
	add $t4, $zero, $zero						
	add $s4, $t2, $zero						
	add $t2, $zero, $zero						
        
	li $v0, 13							
	la $a0, input_buffer_clear						
	li $a1, 0							
	li $a2, 0
	syscall
	
	add $s0, $v0, $zero						
	slt $t1, $v0, $zero						
	bne $t1, $zero, read_file 											
									
	li $v0, 14   							
	add $a0, $s0, $zero						
	la $a1, separator							
	li $a2, 20400							
	syscall
	
	add $s5, $v0, $zero						
	add $a0, $s0, $zero						 
	li $v0, 16							
	syscall			
	
	add $s2, $a1, $zero						
	add $t0, $s2, $zero						
	
	addi $t5, $zero, 13  
#-------------------------------------------------------------------------------------------------------------							
# WORLD
#-------------------------------------------------------------------------------------------------------------
query_world:								# pedir la palabra al usuario						
	add $t1, $zero, $zero
	li $v0, 4							
	la $a0,	get_world_message						
	syscall								

	li $v0, 8 							 
    	la $a0, buffer_world						
    	li $a1, 100							
    	syscall
       
    	la $t1, buffer_world							
    	add $s3, $t1, $zero						
	
	lbu $t4, 0($t1)  						
	addi $s0, $zero, 1						
	addi $s1, $zero, 1						
	
	
search_world:								# bucle que evalua letra por letra, columna por columna, y fila por fila si la palabra existe en la sopa de letras
	lbu $t3, 0($t0)							
	beq $t3, 13, change_row 						
	beq $t3, 10, change_row 					
	beq $t3, $zero, not_found 					
	beq $t3, $t4, build_index
	addi $t0, $t0, 1
	lbu $t3, 0($t0)
	beq $t3, 32, search_world
	addi $s1, $s1, 1						
	j search_world 							    
#-------------------------------------------------------------------------------------------------------------							
# SEARCH
#-------------------------------------------------------------------------------------------------------------  
change_row:								# pasa a la siguiente fila
 	addi $t0, $t0, 2						
 	addi $s0, $s0, 1						
 	addi $s1, $zero, 1						
 	j search_world
 	
change_column:
 	addi $t0, $t0, 1						# pasa a la siguiente columna
 	j search_world
        
build_index: 								# establecer desplazamiento según la busqueda y devuelve el indice
 	addi $t6, $zero, 101 						
 	addi $t7, $zero, 2 						
 	add $t2, $zero, $t0						
 
displace:								# funciones de moviemiento
 	jal rigth
 	bne $s6, $zero,  finish					 	# si el caracter no es igual a 0, finaliza la busqueda por esta función
 	jal left
 	bne $s6, $zero,  finish
 	jal top
 	bne $s6, $zero,  finish
 	jal bottom
 	bne $s6, $zero,  finish			
 	
 	beq $s6, $zero,  change_column					 
 	j query_world
	
finish: 								# restablecer la sopa de letras cuando finaliza una busqueda de palabra
 	j restart_search	
 		
rigth:									# cuando se hace busqueda por la derecha valida y devuelve a la misma 
	addi $sp, $sp, -4 						# posición si la condición de que el caracter evaluado sea igual al 			
	sw $ra, 0($sp) 							# caracter ingresado no se cumple, en el caso contrario hace recursividad
	
	add $t0, $t0, $t7						
 	lbu $t8, 0($t0)							
 	addi $t1, $t1, 1						
 	lbu $t9, 0($t1)							
 	
 	
 	jal validate_final_letter_in_word
 	lw $ra, 0($sp) 							
	addi $sp, $sp, 4
 
 	
 	bne $s6, $zero, get_world  				
 	beq $t8, $t9, rigth						
 	
	add $a0, $t2, $zero						
	j get_first_letter 
	
get_first_letter:
 	add $t0, $a0, $zero						# resetea indice a la posicion del primer caracter evaluado
 	add $t1, $s3, $zero						
 	jr $ra
 	
left: 									# cuando se hace busqueda por la izquierda valida y devuelve a la misma 
 	addi $sp, $sp, -4 						# posición si la condición de que el caracter evaluado sea igual al 
	sw $ra, 0($sp) 							# caracter ingresado no se cumple, en el caso contrario hace recursividad
	sub $t0, $t0, $t7						
 	lbu $t8, 0($t0)							
 	addi  $t1, $t1, 1						
 	lbu $t9, 0($t1)							
 	
 	jal validate_final_letter_in_word						
 	lw $ra, 0($sp) 							
	addi $sp, $sp, 4
 
 	bne $s6, $zero, get_world  				
 	beq $t8, $t9, left

	add $a0, $t2, $zero					
 	j get_first_letter
 
top:									# cuando se hace busqueda por la top valida y devuelve a la misma 
 	addi $sp, $sp, -4 						# posición si la condición de que el caracter evaluado sea igual al 
	sw $ra, 0($sp) 							# caracter ingresado no se cumple, en el caso contrario hace recursividad 

	sub $t0, $t0, $t6						
 	lbu $t8, 0($t0)							
 	add  $t1, $t1, 1						
 	lbu $t9, 0($t1)							
 	
 	jal validate_final_letter_in_word
 	lw $ra, 0($sp) 							
	addi $sp, $sp, 4
 	
 	bne $s6, $zero, get_world  				
 	beq $t8, $t9, top		

	add $a0, $t2, $zero						
 	j get_first_letter
 	
bottom:
 	addi $sp, $sp, -4 						# cuando se hace busqueda por la bottom valida y devuelve a la misma 		
	sw $ra, 0($sp) 							# posición si la condición de que el caracter evaluado sea igual al 
	add $t0, $t0, $t6						# caracter ingresado no se cumple, en el caso contrario hace recursividad 
 	lbu $t8, 0($t0)							
 	add  $t1, $t1, 1						
 	lbu $t9, 0($t1)							
 	jal validate_final_letter_in_word
 	lw $ra, 0($sp) 							
	addi $sp, $sp, 4
 	bne $s6, $zero, get_world  						
 	beq $t8, $t9, bottom						
	add $a0, $t2, $zero						
 	j get_first_letter
 
#-------------------------------------------------------------------------------------------------------------							
# VALIDATIONS
#-------------------------------------------------------------------------------------------------------------  

validate_final_letter_in_word:						# valida si se terminó de evaluar la palabra
	bne $t9, 10, evaluate_end_text										
	addi $s6, $zero, 1										
	jr $ra								
	
get_world:								# retorna posición de la palabra encontrada
 	li $v0, 4
 	la $a0, world_init_message
 	syscall
 	
 	li $v0, 4
 	la $a0, row_message
 	syscall
 	
 	li $v0, 1
 	la $a0, ($s0)
 	syscall
 	
 	li $v0, 4
 	la $a0, column_message
 	syscall
 	
 	li $v0, 1
 	la $a0, ($s1)
 	syscall

 	add $a0, $s2, $zero						
 	j get_first_letter

     
evaluate_end_text:
	addi $s6, $zero, 0						# se evalua si el indice llegó al final de la sopa de letras
	jr $ra

not_found:								# retorna mensaje de que la palabra no fue encontrada	
	li $v0, 4
 	la $a0, not_found_message
 	syscall
 		
order_more_worlds:							# envia mensaje al usuario para determinar si continua o no con la sopa de letras
	addi $sp, $sp, -20 									
	sw $s3, 0($sp) 
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t6, 16($sp)
		
	li $v0, 4						
 	la $a0, search_other_message
 	syscall
 		
 	li $v0, 8 							  
    	la $a0, buffer_search_world					
    	li $a1, 3							
    	syscall
       
    	la $t1, buffer_search_world						
    	add $s3, $t1, $zero
    	lb $t6, 0($t1)

    	lb $t2, s		
	lb $t3, n		
		
	beq $t6, $t2, restart_search
	bne $t6, $t3, invalid
	li $v0, 4
 	la $a0, finish_message
 	syscall
 		
 	j exit
 
invalid: 								# envia información de que la opción ingresada fue invalida
	li $v0, 4			
 	la $a0, options
 	syscall
 		
 	lw $s3, 0($sp) 
    	lw $t1, 4($sp) 
    	lw $t2, 8($sp) 
    	lw $t3, 12($sp) 
    	lw $t6, 16($sp) 							
	addi $sp, $sp, 20  
 		
 	j order_more_worlds

				
restart_search:								# reestablece los indices para una nueva busqueda
    	lw $s3, 0($sp)                                		
    	lw $t1, 4($sp) 
    	lw $t2, 8($sp) 
    	lw $t3, 12($sp) 
    	lw $t6, 16($sp) 						
	addi $sp, $sp, 20  
	add $t0, $s2, $zero
	j query_world  			
	  	
exit: 	li $v0, 10							# Fin
	syscall      	        
