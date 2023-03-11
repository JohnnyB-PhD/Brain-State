from chunk import Chunk
import struct

# imports data from .wav file

filePath = nex.SelectFile()
if not filePath:
    sys.exit()
file = open(filePath, 'rb')

firstChunk = Chunk(file, bigendian=False)
if firstChunk.getname() != b'RIFF':
    raise ValueError('file does not start with RIFF id')
if file.read(4) != b'WAVE':
    raise ValueError('not a WAVE file')

# pass 1: find format chunk
wFormatTag = -1
while file.tell() < firstChunk.chunksize - 8:
    try:
        chunk = Chunk(file, bigendian=False)
    except EOFError:
        break
    chunkname = chunk.getname()
    if chunkname != b'fmt ':
        chunk.skip()
        continue
    wFormatTag, nchannels, framerate, dwAvgBytesPerSec, wBlockAlign, bitsPerSample = struct.unpack_from('<HHLLHH', chunk.read(16))
    break

if wFormatTag == -1:
    raise ValueError('unable to find format specification')
if not wFormatTag in [1, 3] or framerate == 0 or nchannels == 0 or bitsPerSample < 8:
    raise ValueError('unsupported format specification')

# pass 2: find data chunk and load data
file.seek(12)
while file.tell() < firstChunk.chunksize - 8:
    try:
        chunk = Chunk(file, bigendian=False)
    except EOFError:
        break
    chunkname = chunk.getname()
    if chunkname != b'data':
        chunk.skip()
        continue
    
    # read data
    valuesBytes = file.read(chunk.chunksize)
    numSamples = int(chunk.chunksize/(bitsPerSample/8))
    numSamplesPerChannel = int(numSamples/nchannels)
    valuesAsList = []
    if wFormatTag == 3 and bitsPerSample == 32:
        values = struct.unpack('f' * numSamples, valuesBytes)
        # assuming that values in file are in Volts. 
        # we need to convert values to milliVolts
        valuesAsList = [x*1000.0 for x in values]
    else:
        fmt = '?'
        if wFormatTag == 1:
            if bitsPerSample == 16:
                fmt = 'h'
            if bitsPerSample == 8:
                fmt = 'B'
        if fmt == '?':
            raise ValueError('unsupported data format')
        values = struct.unpack(fmt * numSamples, valuesBytes)
        # scaling is unknown?
        valuesAsList = [float(x) for x in values]
        
    # create data document and set continuous variables
    freq = float(framerate)
    doc = nex.NewDocument(freq)
    times = []
    for i in range(numSamplesPerChannel):
        times.append(i/freq)   

    for i in range(nchannels):
        singleChanValues = [valuesAsList[index] for index in range(i, numSamples, nchannels)]
        name = 'ContChannel_{}'.format(i+1)
        doc[name] = nex.NewContVarWithFloats(doc, freq)
        doc[name].SetContVarTimestampsAndValues(times, singleChanValues)
        nex.Select(doc, doc[name])
    # exit from loop looking at 'data' chunk
    break
    
file.close()

doc.SetProperty('DocumentPath', filePath)




