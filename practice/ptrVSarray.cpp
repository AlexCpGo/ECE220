# include <stdio.h>

int main(){
	int i = 5;
	int *ptr = &i;
	int *a = ptr;
	printf("Orinally:\n &ptr is %d\n",&ptr);
	printf("ptr is %d\n",ptr);
	printf("*ptr is %d\n", *ptr);
	printf("*a is %d\n",*a);
	printf("a is %d\n\n",a);
	
	*ptr = 3;
	printf("Now:\n &ptr is %d\n",&ptr);
	printf("ptr is %d\n",ptr);
	printf("*ptr is %d\n", *ptr);
	printf("*a is %d\n",*a);
	printf("a is %d",a);
}  
