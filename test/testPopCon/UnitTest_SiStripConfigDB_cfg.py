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
    ForceVersions = cms.untracked.bool(True),
    ForceCurrentState = cms.untracked.bool(False),
    CablingVersion = cms.untracked.vuint32(67, 8),
    FecVersion = cms.untracked.vuint32(375, 0),
    DcuDetIdsVersion = cms.untracked.vuint32(8, 0),
    FedVersion = cms.untracked.vuint32(469, 0),
    PartitionName = cms.untracked.string('TI_08-AUG-2008_1'),
    DcuPsuMapVersion = cms.untracked.vuint32(0, 0)
    ),
    PartTOB = cms.untracked.PSet(
    ForceVersions = cms.untracked.bool(True),
    ForceCurrentState = cms.untracked.bool(False),
    CablingVersion = cms.untracked.vuint32(66, 5),
    FecVersion = cms.untracked.vuint32(376, 0),
    DcuDetIdsVersion = cms.untracked.vuint32(8, 0),
    FedVersion = cms.untracked.vuint32(470, 0),
    PartitionName = cms.untracked.string('TO_08-AUG-2008_1'),
    DcuPsuMapVersion = cms.untracked.vuint32(0, 0)
    )
    )
process.SiStripConfigDb.TNS_ADMIN = ''


process.FedCablingFromConfigDb = cms.ESSource("SiStripFedCablingBuilderFromDb",
                                              CablingSource = cms.untracked.string('UNDEFINED')
                                              )


process.reader = cms.EDAnalyzer("SiStripFedCablingReader")


process.p1 = cms.Path(process.reader)


