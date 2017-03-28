#!/usr/bin/python

#class SendMail via http://www.oschina.net/code/snippet_221343_49994
#A few modifications: Add Cc support ; print -> return string.

from email.MIMEText import MIMEText
from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email import Utils, Encoders
import mimetypes, sys,smtplib,socket,getopt

class SendMail:
    def __init__(self,smtp_server,from_addr,to_addr,cc_addr,user,passwd):
        self.mailserver=smtp_server
        self.from_addr=from_addr
        self.to_addr=to_addr
	self.cc_addr=cc_addr
        self.username=user
        self.password=passwd
    def attachment(self,filename):
        fd=open(filename,'rb')
        filename=filename.split('/')
        mimetype,mimeencoding=mimetypes.guess_type(filename[-1])        
        if (mimeencoding is None) or (mimetype is None):
            mimetype='application/octet-stream'       
        maintype,subtype=mimetype.split('/')
        if maintype=='text':
            retval=MIMEText(fd.read(), _subtype=subtype, _charset='utf-8')          
        else:
            retval=MIMEBase(maintype,subtype)
            retval.set_payload(fd.read())
            Encoders.encode_base64(retval)
            retval.add_header('Content-Disposition','attachment',filename=filename[-1])
            fd.close()
        return retval
    def msginfo(self,msg,subject,filename): 
        # message = """Hello, ALL
        #This is test message.
        #--Anonymous"""
        message=msg
        msg=MIMEMultipart()
        msg['To'] = self.to_addr
        msg['From'] = self.from_addr
        msg['Cc'] = self.cc_addr
        msg['Date'] = Utils.formatdate(localtime=1)
        msg['Message-ID'] = Utils.make_msgid()
        if subject:
            msg['Subject'] = subject
        if message:
	    #utf8-encoding
            body=MIMEText(message,_subtype='plain', _charset='utf-8')
            msg.attach(body)
        #for filename in sys.argv[1:]:
        if filename:
            msg.attach(self.attachment(filename))
        return msg.as_string()
    def send(self,msg=None,subject=None,filename=None):
        try:
            s=smtplib.SMTP(self.mailserver)
            try:
                s.login(self.username,self.password)
            except smtplib.SMTPException,e:
                print "Authentication failed:",e
                sys.exit(1)
	    if cc_addr:
                to_addrs=self.to_addr+','+self.cc_addr
            else:
                to_addrs=self.to_addr

	    s.sendmail(self.from_addr, to_addrs.split(','), self.msginfo(msg,subject,filename))
        except (socket.gaierror,socket.error,socket.herror,smtplib.SMTPException),e:
            return "*** Your message may not have been sent!\n" + e            
        else:
            return "OK"

#Main
if __name__=='__main__':
    def usage():
        print """Useage:%s [-h] -s <SMTP Server> -f <FROM_ADDRESS> -t <TO_ADDRESS> -u <USER_NAME> -p <PASSWORD> [-S <MAIL_SUBJECT> -m <MAIL_MESSAGE> -F <ATTACHMENT>]
   Mandatory arguments to long options are mandatory for short options too.
     -f, --from=   Sets the name of the "from" person (i.e., the envelope sender of the mail).
     -t, --to=   Addressee's address. -t "test@test.com,test1@test.com".
     -c, --cc=   CC Addressee's address. -c "test2@test.com,test3@test.com".
     -u, --user=   Login SMTP server username.
     -p, --pass=   Login SMTP server password.
     -S, --subject=  Mail subject.
     -m, --msg=   Mail message.-m "msg, ......."
     -F, --file=   Attachment file name.
     
     -h, --help   Help documen.    
   """ %sys.argv[0]
        sys.exit(3)
    try:
	options,args=getopt.getopt(sys.argv[1:],"hs:f:t:c:u:p:S:m:F:","--help --server= --from= --to= --cc= --user= --pass= --subject= --msg= --file=",)
    except getopt.GetoptError:
        usage()
        sys.exit(3)
 
    server=None
    from_addr=None
    to_addr=None
    cc_addr=None
    username=None
    password=None
    subject=None
    filename=None
    msg=None
    for name,value in options:
        if name in ("-h","--help"):
            usage()
        if name in ("-s","--server"):
            server=value
        if name in ("-f","--from"):
            from_addr=value
        if name in ("-t","--to"):
            to_addr=value
        if name in ("-c","--cc"):
            cc_addr=value
        if name in ("-u","--user"):
            username=value
        if name in ("-p","--pass"):
            password=value
        if name in ("-S","--subject"):
            subject=value
        if name in ("-m","--msg"):
            msg=value
        if name in ("-F","--file"):
            filename=value
if server and from_addr and to_addr and username and password:
    test=SendMail(server,from_addr,to_addr,cc_addr,username,password)
    strResult=test.send(msg,subject,filename)
    print strResult
else:
    usage()
