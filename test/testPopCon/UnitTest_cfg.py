import FWCore.ParameterSet.Config as cms

process = cms.Process("o2o")

process.MessageLogger = cms.Service("MessageLogger",
    debugModules = cms.untracked.vstring(''),
    destinations = cms.untracked.vstring('UnitTestWriter.log')
)

process.source = cms.Source("EmptyIOVSource",
    lastValue = cms.uint64(1),
    timetype = cms.string('runnumber'),
    firstValue= cms.uint64(1),
    interval = cms.uint64(1)
)

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(1)
)

process.load("OnlineDB.SiStripO2O.SiStripO2OCalibrationFactors_cfi")
process.SiStripCondObjBuilderFromDb = cms.Service("SiStripCondObjBuilderFromDb",
    process.SiStripO2OCalibrationFactors
)

process.load("CondCore.DBCommon.CondDBCommon_cfi")
process.CondDBCommon.connect = 'sqlite_file:dbfile.db'
process.CondDBCommon.DBParameters.messageLevel = 4
process.CondDBCommon.DBParameters.authenticationPath = '/nfshome0/xiezhen/conddb'
process.PoolDBOutputService = cms.Service("PoolDBOutputService",
    process.CondDBCommon,
    BlobStreamerName = cms.untracked.string('TBufferBlobStreamingService'),
    logconnect = cms.untracked.string('sqlite_file:log.db'),
    timetype = cms.untracked.string('runnumber'),
    toPut = cms.VPSet(cms.PSet(
        record = cms.string('SiStripNoisesRcd'),
        tag = cms.string('SiStripNoise_UnitTest')
    ))
)

process.CommonSiStripPopConParams = cms.PSet(
    SinceAppendMode = cms.bool(True),
    Source = cms.PSet(
        since = cms.untracked.uint32(54507),
        name = cms.untracked.string('default')
    ),
    loggingOn = cms.untracked.bool(True)
)

process.siStripPopConNoise = cms.EDAnalyzer("SiStripPopConNoiseUnitTest",
    process.CommonSiStripPopConParams,
    record = cms.string('SiStripNoisesRcd')
)

process.siStripPopConNoise.Source.name = 'siStripPopConNoise'

process.pped = cms.Path(process.siStripPopConNoise)


