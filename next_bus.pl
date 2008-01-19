#!/usr/bin/env perl
# set stops to the bus stop numbers you like and buses to helpful bus numbers.

@stops = (2002, 2893);
@buses = (4, 6, 106);

$buses = join "|",@buses;

$url = "http://www.edmonton.ca/portal/server.pt/gateway/PTARGS_0_0_341_239_0_43/http%3B/AppServer/ExternalSupported/Transit/BusStopSchedule_Results.aspx";

($date = `date +%Y+%b+%d`) =~ s/\n//;
$hour = `date +%k` * 60;
($minute = `date +%M`) =~ s/\n//;

foreach $stop (@stops) {
    open WGET, "wget --post-data='__EVENTTARGET=&__EVENTARGUMENT=&txtTravelDate=$date&cboHour=$hour&cboMinute=$minute&txtBusStopNumber=$stop&cmdBusStopScheduleSubmit=Get+Bus+Stop+Schedule' '$url' -O - |";
    $buf = "";
    while (<WGET>) {
        if (/(lblBusStopNumberLabel|lblDateOfTravelLabel|lblLocationLabel|lblDirectionLabel|lblDepartureDate)/) {
            />([^<]*)<\//;
            $label = $1;
        } elsif (/(lblBusStopNumber|lblDateOfTravel|lblLocation|lblDirection)/ || /lnkRouteNumber/ && />($buses)</) {
            />([^<]*)<\//;
            $buf .= "$label $1\n";
        }
    }
    print $buf
}
