void		  Seqxewrt(unsigned int dst, unsigned char *src, unsigned int len);
unsigned char xeread(unsigned int addr );

void          IntE2wrt(unsigned int addr, unsigned char b );
unsigned char IntE2read(unsigned int addr );



void WriteinExE2prom(unsigned int dst, unsigned char *src, unsigned int len)
{
	Seqxewrt(dst, src, len);
}


void ReadfromExE2prom(unsigned int src, unsigned char *dst, unsigned int len)
{
	while (len--)
	{
		*dst++ = xeread(src);
		src++;
	}
}

void WriteinIntE2prom(unsigned int dst, unsigned char *src, unsigned int len)
{

	while (len--)
	{
		IntE2wrt(dst, *src++);
		dst++;
	} 
}

void ReadfromIntE2prom(unsigned int src, unsigned char *dst, unsigned int len)
{
	while (len--)
	{
		*dst++ = IntE2read(src);
		src++;
	}
}
