import csv, sys

alias = {'Julien Malik': 'JM2',
         'Jordi Inglada': 'JI',
         'inglada': 'JI',
         'Manuel Grizonnet': 'MG',
         'manuel': 'MG',
         'Manuel GRIZONNET': 'MG',
         'jmichel': 'JM',
         'Julien Michel <CS>': 'JM',
         'michelj': 'JM',
         'Julien Michel': 'JM',
         'Emmanuel Christophe': 'EC',
         'Otmane Lahlou': 'OL',
         'Maintenance <nomail>': 'x',
         'root': 'x',
         'grizonnetm': 'MG',
         'otbval': 'x',
         'otbtesting': 'x',
         'OTB Bot': 'x',
         'apache': 'x',
         'orfeo': 'x',
         'www-data': 'x',
         'Administrateur': 'x',
         'otbval <CS-Communications & Systems>': 'x',
         'tfeuvrie': 'TF',
         'cyrille': 'CV',
         'cvallade': 'CV',
         'Cyrille Valladeau <CS>': 'CV',
         'cyrille-Ubuntu': 'CV',
         'Cyrille Valladeau': 'CV',
         'Aurelien Bricier': 'AB',
         'aurelien': 'AB',
         'Sebastien Dinot': 'SD',
         'gborrut': 'GB',
         'Patrick Imbo <CS>': 'PI',
         'Patrick Imbo': 'PI',
         'patrick': 'PI',
         'Mathieu Deltorre <CS>': 'MD',
         'mdeltorr': 'MD',
         'Caroline Ruffel <CS>': 'CR',
         'romain': 'RG',
         'Romain G.': 'RG',
         'Romain Garrigues <CS>': 'RG',
         'etienne': 'EB',
         'Etienne Bougoin': 'EB',
         'guillaume': 'GB',
         'Guillaume Borrut <CS>': 'GB',
         'Guillaume Borrut': 'GB',
         'Amit Kulkarni': 'AK',
         'massimo': 'MDS',
         'Tisham': 'TD',
         'Tisham <>': 'TD',
         'Conrad Bielski': 'CB',
         'Gregoire Mercier': 'GM',
         'mercierg': 'GM',
         'Chia Aik Song': 'CAS',
         'Yin Tiangang': 'YT',
         'Guillaume Pasero': 'GP',
         'Jonathan Guinet':'JG',
         'jonathan guinet':'JG',
         'jonathan':'JG',
         'jguinet':'JG',
         'Mickael Savinaud':'MS',
         'Micka\xc3\xabl':'MS',
         'Arnaud Jaen': 'AJ',
         'rosa': 'RR',
         'thomas': 'TF',
         'thomasf': 'TF',
         'Thomas Feuvrier <CS>': 'TF',
         'Thomas Feuvrier': 'TF',
         'Thomas Feuvrier <CS-Communications & Systems>': 'TF'}

#Number of modified files above which the commit is not shown
maxFiles = 50

csv.field_size_limit(1000000000)

def formatDate(datestring):
    datelst = datestring.split(' ')
    return int(datelst[0])+int(datelst[1])

def formatUser(userstring):
    return alias[userstring.strip()]

def ProcessCsv(csv_file, output_file, prefix):
    output = open(output_file, 'w')
    csv_reader = csv.reader(open(csv_file, 'r'))
#    loglist = []
    for row in csv_reader:
        date = formatDate(row[0])
        user = formatUser(row[1])
        file_list = row[2].strip().split(' ')
        file_adds = row[3].strip().split(' ')
        file_dels = row[4].strip().split(' ')
#        print file_list
#        print len(file_list)
        if (len(file_list) < 50) and (user != 'x'):
            for f in file_list:
                if f != '':
                    if f in file_adds: mod='A'
                    elif f in file_dels: mod='D'
                    else: mod='M'
                    logstring = str(date)+'|'+user+'|'+mod+'|'+prefix+'/'+f+'\n'
#                    print logstring
                    output.write(logstring)
#                    loglist.append(logstring)

#    loglist = sorted(loglist)
#    for logstring in loglist:
#        output.write(logstring)


def main():
    prefix=sys.argv[1]
    ProcessCsv('output-'+prefix+'.csv', 'output-'+prefix+'.log', prefix)

if __name__ == '__main__':
  main()
