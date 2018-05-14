int func(int);

int main(int q) {

	int a, b, c;
	float x, y, z;

	read a, b, c, x, y, z;

	a+b-c;
	x*y/z;

	if(a-b > 4){
		read a;
	}
	else {
		if(x*y >=z)
			write "x*y >= z";
		else
			write "x*y < z";

		while(z <= 5.0) {
			write "this is in the while loop";
			z=z+1.0;
		}

		write func(a-b+c);
	}

}

int func(int z) {
	write "entered func";
	return z*2;
}
