/*

 demo of dlang json functions
 
 	Run the demo, then ddit demo.json and note that the keys are written in ascending sort order.
	You could create the JSONValue as follows: 	"_1name", "_2description", "_3dependencies"
	Then open the demo.json file and remove the numbers _1, _2, _3.
	The result is a json file in the order of your preference, versus the default key sort order
	

*/

module dlang.modules.json;

import std.stdio;
import std.json;
import std.conv : to;
import std.file;

string dubString;

enum JSON_FILE = "demo.json";

void main() {
	
	//remove existing json file, if any
	if (exists(JSON_FILE)) remove(cast(string)JSON_FILE);
	
	//read json file, does not exists so create a new one
	JSONValue json = readJSON(JSON_FILE);

	//show contents
	writeln("New json file contents:\n");

	writeln("name         =", json["name"]);
	writeln("description  =", json["description"]);
	writeln("dependencies =", json["dependencies"]);

	//modify
	json["name"]			= "New Name";
	json["description"]		= "New Description";
	json["dependencies"]	= "{}";					//no dependencies
	
	//write
	writeJSON(JSON_FILE, json);
	
	//verify
	json = readJSON(JSON_FILE);
	
	writeln("\nModified json file contents:\n");

	writeln("name         =", json["name"]);
	writeln("description  =", json["description"]);
	writeln("dependencies =", json["dependencies"]);
	
	writeln("\nDemo complete, reads comments about how the keys are written in ascending sort order.");

}

JSONValue readJSON(string jsonFile) {

	//if json file not exists, return a dub.json template
    if (!exists(jsonFile)) {
   		JSONValue json = [ "name": "TBD", "description": "TBD", "dependencies": "TBD" ];
       	return json;
    }
	
	string jsonString;
	
	//read json
	try
    {
       	jsonString = readText(jsonFile);
    }
    catch (Exception ex)
    {
        writeln("Error reading " ~ jsonString);
    }

	return parseJSON(jsonString);
	
}

void writeJSON(string jsonFile, JSONValue jsonValue) {

	
	//backup
	if (exists(jsonFile)) copy(jsonFile, jsonFile ~ ".bak");
	
	//create or overwrite
	try
    {
		File file = File(jsonFile, "w");
		file.writeln(jsonValue.toPrettyString);
		file.close();
   }
    catch (FileException ex)
    {
		writeln("Error writing " ~ jsonFile);
    }
}
