#coding: utf-8
'''
Leia dois valores inteiros. A seguir, calcule o produto entre estes dois valores e atribua esta operação à variável PROD. 
A seguir mostre a variável PROD com mensagem correspondente.   

Entrada

O arquivo de entrada contém 2 valores inteiros.

Saída

Imprima a variável PROD conforme exemplo abaixo, com um espaço em branco antes e depois da igualdade. 
Não esqueça de imprimir o fim de linha após o produto, caso contrário seu programa apresentará a mensagem: “Presentation Error”.
'''

def main():
	valor_1 = int(input())
	valor_2 = int(input())

	PROD = valor_1 * valor_2

	print'PROD = %d' % PROD

if __name__ == '__main__':
	main()