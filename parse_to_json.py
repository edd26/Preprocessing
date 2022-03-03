from collections import OrderedDict
import json

FILE_NAME = "design.fsf"

options_dictionary = OrderedDict()

with open(FILE_NAME) as infile:
    
    option_data = []
    for line in infile:
        if line == "":
            break
        else:
            option_data.append(line)
    
    for option in option_data:
        
        
            
        # outfile.write(line)

