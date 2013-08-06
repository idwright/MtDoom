import os
import sys
import urllib2
import ConfigParser
from cmislib.model import CmisClient,Folder

configFileName='ganesha/data/alfresco.cfg'
cmisConfigSectionName='cmis_repository'

config = ConfigParser.RawConfigParser()
config.read(configFileName)

def uploadArchiveFile(srcFolder, dest, filename):
  someFile = open(srcFolder+"/"+filename)
  someDoc = dest.createDocument(filename, contentFile=someFile)

client = CmisClient(config.get(cmisConfigSectionName, "serviceUrl"),config.get(cmisConfigSectionName, "user_id"),config.get(cmisConfigSectionName, "password"))
print client
repo = client.defaultRepository
print repo
someFolder = repo.getObjectByPath('/Sites/pf-web-app/documentLibrary/Data Releases')
baseFolder=sys.argv[1]
archiveFolder='archive/'+baseFolder
if not os.path.exists(archiveFolder):
    sys.exit('ERROR: Folder to upload %s was not found!' % archiveFolder)
newFolder=someFolder.createFolder(baseFolder)
versions='alfresco_file_versions.txt'
json='alfresco.json'
dbdump='pf21.sql.gz'

uploadArchiveFile(archiveFolder,newFolder,versions)
uploadArchiveFile(archiveFolder,newFolder,json)
uploadArchiveFile(archiveFolder,newFolder,dbdump)

