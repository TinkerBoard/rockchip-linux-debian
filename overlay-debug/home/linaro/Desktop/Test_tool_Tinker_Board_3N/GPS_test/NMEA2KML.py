import sys
import re
import math

#style:http://www.google.com/intl/en_us/mapfiles/ms/icons/red-dot.png

def main():

    in_filename = sys.argv[1]
    out_filename = sys.argv[2]

    kml_file = open(out_filename, 'w')

    kml_file.write('<?xml version="1.0"  encoding="UTF-8"?>\n')
    kml_file.write('<kml xmlns="http://www.google.com/earth/kml/2">\n')
    kml_file.write('<Document>\n')
    kml_file.write('<name>Point Features</name>\n')
    kml_file.write('<description>Point Features</description>\n')
    kml_file.write('''<Style id="roadStyle">
    <LineStyle>
      <color>ff4444ff</color>
      <width>3</width>
    </LineStyle>
    </Style>
    <Style id="lightblue">
        <IconStyle>
            <Icon>
                <href>https://maps.gstatic.com/mapfiles/ms2/micons/lightblue.png</href>
            </Icon>
        </IconStyle>
    </Style>
    <Style id="blue">
        <IconStyle>
            <Icon>
                <href>https://maps.gstatic.com/mapfiles/ms2/micons/blue.png</href>
            </Icon>
        </IconStyle>
    </Style>
    <Style id="red">
        <IconStyle>
            <Icon>
            <href>https://maps.gstatic.com/mapfiles/ms2/micons/red.png</href>
            </Icon>
        </IconStyle>
    </Style>
    <Style id="green">
        <IconStyle>
        <Icon>
        <href>https://maps.gstatic.com/mapfiles/ms2/micons/green.png</href>
        </Icon>
    </IconStyle>
    </Style>
    <Style id="purple">
        <IconStyle>
        <Icon>
        <href>https://maps.gstatic.com/mapfiles/ms2/micons/purple.png</href>
        </Icon>
    </IconStyle>
    </Style>
    <Style id="orange">
        <IconStyle>
        <Icon>
        <href>https://maps.gstatic.com/mapfiles/ms2/micons/orange.png</href>
        </Icon>
    </IconStyle>
    </Style>
    <Style id="yellow">
        <IconStyle>
        <Icon>
        <href>https://maps.gstatic.com/mapfiles/ms2/micons/yellow.png</href>
        </Icon>
    </IconStyle>
    </Style>
    <Style id="white">
        <IconStyle>
        <Icon>
        <href>http://maps.google.com/mapfiles/kml/paddle/wht-blank_maps.png</href>
        </Icon>
        </IconStyle>
    </Style>
    <Style id="style15">
        <LineStyle>
            <color>7FC000C0</color>
            <width>7</width>
        </LineStyle>
    </Style>\n''')
    for line in open(in_filename, 'r'):
        
        #if not line:
        #    continue

        # Try to catch corrupt lines early
        #if not line.startswith('$GP'):
        #    continue

        # Skip any sentence other than GPGGA
        #if not line.startswith('$GNGGA'):
        #    continue

        if '$GNGGA' in line:
            #print("line:%s"% line)  
            list = line.split(',')

            kml_file.write('<Placemark>\n')
            hhmmss = list[1]
            time = hhmmss[0:2] + ":" + hhmmss[2:4] + ":" + hhmmss[4:10]
            lat2 = float(list[2][:2]) + (float(list[2][2:]) / 60)
            latitude = list[2] + " " + list[3]
            lon2 = float(list[4][:3]) + (float(list[4][3:]) / 60)
            longtitude = list[4] + " " + list[5]
            altitude = list[9]
            fixmode=list[6]
            kml_file.write('<name>%s</name>\n' % time)
            # fixmode 0:No fix, 1: 3D , 2: 3D+DR , 3:DR
            if fixmode == '0':
                kml_file.write('<styleUrl>#red</styleUrl>\n')
            elif fixmode == '1':
                kml_file.write('<styleUrl>#green</styleUrl>\n')    
            elif fixmode == '2':
                kml_file.write('<styleUrl>#lightblue</styleUrl>\n')
            elif fixmode == '6':
                kml_file.write('<styleUrl>#purple</styleUrl>\n')
            else:
                kml_file.write('<styleUrl>#white</styleUrl>\n')
            kml_file.write('<Point>\n')
            kml_file.write('<coordinates> %s,%s,%s </coordinates>\n' % (lon2,lat2,altitude))
            kml_file.write('</Point>\n')
            kml_file.write('</Placemark>\n')
    kml_file.write('</Document>\n')
    kml_file.write('</kml>\n')
    kml_file.close();


if __name__ == '__main__':
    main()
