import csv

outfile = 'ipl-data.sql'
dire = 'csv-files/CSVs/'

relations = ['team', 'venue', 'player', 'match', 'ball_by_ball', 'player_match']

# +
#relat = 'match'    #loop
# -

import os.path
if(os.path.isfile(outfile)): 
    file = open(outfile,"r+")
    file. truncate(0)
    file. close()

old_qu = 'delete from '
for relat in reversed(relations):
    qu = old_qu
    qu = qu + relat + ';'
    with open(outfile, 'a') as f:
        print(qu, file=f)
    #print(qu)



for relat in relations:
    with open(relat + '.csv', newline='') as csvfile:
        stud = csv.DictReader(csvfile)
        old_qu = 'insert into ' + relat + ' values ('
        
        for row in stud:
            qu = old_qu
            for key, value in row.items():
                if(value == 'NULL'):
                    qu = qu + 'null,'
                else:
                    qu = qu + '\'' + value + '\'' + ','
                    
            qu = qu[:-1] + ');'
        
            with open(outfile, 'a') as f:
                print(qu, file=f)
            #print(qu)















