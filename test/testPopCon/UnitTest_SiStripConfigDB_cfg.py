# The following comments couldn't be translated into the new config version:

# upload to database 

#string timetype = "timestamp"    

import FWCore.ParameterSet.Config as cms

process = cms.Process("Reader")

process.MessageLogger = cms.Service("MessageLogger",
    debugModules = cms.untracked.vstring(''),
    CablingReader = cms.untracked.PSet(
        threshold = cms.untracked.string('INFO')
    ),
    cout = cms.untracked.PSet(
        threshold = cms.untracked.string('INFO')
    ),
    destinations = cms.untracked.vstring('UnitTest_SiStripConfigDB.log')
)

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(1)
)
process.source = cms.Source("EmptySource",
    numberEventsInRun = cms.untracked.uint32(1),
    firstRun = cms.untracked.uint32(1)
)

process.load("OnlineDB.SiStripConfigDb.SiStripConfigDb_cfi")
process.SiStripConfigDb.UsingDb = True
process.SiStripConfigDb.ConfDb = ''
process.SiStripConfigDb.Partitions = cms.untracked.PSet(
    PartTIBD = cms.untracked.PSet(
    PartitionName = cms.untracked.string('TI_08-AUG-2008_1'),
    DcuDetIdsVersion = cms.untracked.vuint32(9, 0),
    RunNumber = cms.untracked.uint32(55212)
    ),
    PartTECP = cms.untracked.PSet(
    PartitionName = cms.untracked.string('TP_08-AUG-2008_1'),
    DcuDetIdsVersion = cms.untracked.vuint32(9, 0),
    RunNumber = cms.untracked.uint32(54986)
    ),
     PartTECM = cms.untracked.PSet(
    PartitionName = cms.untracked.string('TM_08-AUG-2008_1'),
    DcuDetIdsVersion = cms.untracked.vuint32(9, 0),
    RunNumber = cms.untracked.uint32(54951)
    ),
     PartTOB = cms.untracked.PSet(
    PartitionName = cms.untracked.string('TO_08-AUG-2008_1'),
    DcuDetIdsVersion = cms.untracked.vuint32(9, 0),
    RunNumber = cms.untracked.uint32(55112)
    )
    )
process.SiStripConfigDb.TNS_ADMIN = ''


process.FedCablingFromConfigDb = cms.ESSource("SiStripFedCablingBuilderFromDb",
                                              CablingSource = cms.untracked.string('UNDEFINED')
                                              )


process.reader = cms.EDAnalyzer("SiStripFedCablingReader")


process.p1 = cms.Path(process.reader)


