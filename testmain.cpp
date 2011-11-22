//###########################################################\\
//#															#\\
//#	Test Main	3. Semester Projekt Rob/Tek					#\\
//#															#\\
//#	Frederik Hagelskjær										#\\
//#															#\\
//###########################################################\\

#define BUFFERSIZE 1000
#define INPUTUP "inputup.dat"
#define INPUTDOWN "inputdown.dat"
#define OUTPUTUP "outputup.dat"
#define OUTPUTDOWN "outputdown.dat"




#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <boost/circular_buffer.hpp>

//inkluder det du ønsker at teste

//#include <"TEST">

using namespace std;


string inputfile1 = INPUTUP,inputfile2 = INPUTDOWN, outputfile1 = OUTPUTUP, outputfile2 = OUTPUTDOWN;
char mychar, newchar;

int main()
{
	ifstream inputup;
	ifstream inputdown;
	ofstream outputup;
	ofstream outputdown;
	
		inputup.open(inputfile1.c_str());		
		inputdown.open(inputfile2.c_str());
	
	if(inputup.fail() || inputdown.fail() )
	{
		cerr << "Error opening input file";
		exit(1);
	}
	
	outputup.open(outputfile1.c_str());
	outputdown.open(outputfile2.c_str());
		
	
	boost::circular_buffer<char> dscbi(BUFFERSIZE);
	boost::circular_buffer<char> dscbo(BUFFERSIZE);
	boost::circular_buffer<char> uscbi(BUFFERSIZE);
	boost::circular_buffer<char> uscbo(BUFFERSIZE);

	
	while( !inputup.eof() )
	{
		inputup.get (mychar); 
		dscbi.push_back(mychar);
	}	

	while( !inputdown.eof() )
	{
		inputdown.get (mychar); 
		uscbi.push_back(mychar);
	}

//	call til laget ( *dscbi, *dscbo, *uscbi, *uscbo, BUFFERSIZE)

	//skriv til en fil

	while(!uscbi.empty())
	{
		newchar = uscbi.front();
		uscbi.pop_front();
		outputup << newchar;
	}

	while(!dscbi.empty())
	{
		newchar = dscbi.front();
		dscbi.pop_front();
		outputdown << newchar;
	}

	
	return 0;
				
}
