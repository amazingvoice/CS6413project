int main() /* header is wrong */
{
  int n, c, k;
 
  write "Enter an integer in decimal number system\n"; /* There's no official support for special characters in strings. */
  
  read n;
 
  write "in binary number system is:\n",n;
 
 /* there's no FOR in our language; and no != */
  for (c = 31; c != 0; c--)
  {
    k = n >> c;  /* there is no >> in our language */
 
    if (k = 1)
      write "1";
    else
      write("0");
  }
 
  printf("\n");
 
  return 0;
}
