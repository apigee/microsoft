conn="DefaultEndpointsProtocol=https;AccountName=apigeeedgetrail;AccountKey=XR2H0KS/TXL6IVeUrmD4jcD0YXpXd2OfskrHq1IeRMFbWgwLpUEGqnmkqVsbH3FcPhR1Sqwm8mI5vEibTG4hIw==;EndpointSuffix=core.windows.net"
azure storage container list vhds -c $conn
azure storage container sas create vhds rl 01/01/2019 -c $conn --start 01/01/2018
