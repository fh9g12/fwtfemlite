function writeFileStamp(fid)
    %writeFileStamp Stamps the file with the following
    %information:
    %
    %   - Date & Time
    %   - User name
    %   - Version of MATLAB
    %   - Version of MATRAN software

    t   = datetime('now', 'TimeZone', 'local', 'Format', 'd-MMM-y HH:mm:ss');
    usr = [getenv('username'), ' (', getenv('computername'), ')'];
    aV  = 'v0';
    mV  = version;

    stamp = {'Created on', 'Created by', 'Matlab ver', 'ALENA ver' ; t, usr, mV, aV};

    fprintf(fid, '$ File information\n$\n');
    fprintf(fid, '$\t- %-12s: %s\n', stamp{:});

end

