conn="DefaultEndpointsProtocol=https;AccountName=apigeeedgetrail;AccountKey=;EndpointSuffix=core.windows.net"
azure storage container list vhds -c $conn
azure storage container sas create vhds rl 01/01/2019 -c $conn --start 01/01/2018
