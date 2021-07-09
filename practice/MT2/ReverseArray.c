# include <stdio.h>
void ReverseArray(int array[], int size){
	int start = 0, end = size - 1, temp;
	if (start < end){
		temp = array[start];
		array[start] = array[end];
		array[end] = temp;
		
		ReverseArray(array + 1, size - 2);
	}
} 


int main(){
	int array[5],i;
	
	for (i = 0; i < 5; i++){
		array[i] = i;
	}
	
	ReverseArray(array,5);
	
	printf("Reversedarray is \n");
	for (i = 0; i < 5; i++){
		printf("%d",array[i]);
	}
	printf("\n");
}
