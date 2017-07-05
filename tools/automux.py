# maplemuxtool v1.2
import os
import subprocess
import sys
import getopt
"""
https://forer.cn/archives/2665 利用FFmpeg和python批量混流
cmd中
python 脚本路径 -v 视频路径 -a 音频路径 -n [num]开始数字~[num]结束数字 -t 音轨号(第一条音轨一般为0)
仅-v 必填 -a 默认同-v -n默认1~1 -t默认0
"""
def mainmux(vedioinput,audioinput,vedioselect = r"0",audioselect = r"0",vediofilter = r"copy",audiofilter = r"copy"):
    #组合输出路径
    p = os.path.split(vedioinput)
    pe = os.path.splitext(p[1])
    filepath = p[0]
    filename = pe[0]
    fileextraname = pe[1]
    output = os.path.join(filepath,filename+"_mmux"+fileextraname)
    #在下面一行改ffmpeg位置
    command = r'ffmpeg -i '+'"'+vedioinput+'"'+' -i '+'"'+audioinput+'"'+' -c:v '+vediofilter+\
              ' -map 0:v:'+vedioselect+' -c:a '+audiofilter+' -map 1:a:'+audioselect+' -y '+'"'+output+'"'
    print(command)
    a = subprocess.Popen(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,stdin=subprocess.PIPE)
    b = a.communicate(b'y')
    return(b[0].decode("utf-8"))
    #return command

def autofilename(filename,firstnum=1,lastnum=1):
    filenames=[]
    for number in range(int(firstnum),int(lastnum)+1):
        if number < 10:
            number='0'+str(number)
        filename_edited=filename.replace('[num]',str(number))
        filenames.append(filename_edited)
        # print(number)
    return filenames

def automux(vediofile,audiofile,firstnum=1,lastnum=1,audiotrack=0,audiofilter = ""):
    # vediofile = r"E:\python\automux\[num].mp4"
    # audiofile = r"E:\python\automux\[num]_AAC.aac"
    audiotrack = str(audiotrack)
    vediofilenames = autofilename(vediofile,firstnum,lastnum)
    audiofilenames = autofilename(audiofile,firstnum,lastnum)
    #print(vediofilenames)
    #print(audiofilenames)
    num = 0
    vediotrack='0'
    for v in vediofilenames:
        r = mainmux(v,audiofilenames[num],vediotrack,audiotrack,audiofilter)
        num = num+1
        print(r)

if __name__ == '__main__':
    argv_list = []
    argv_list = sys.argv[1:]
    try:
        opts, args = getopt.getopt(argv_list,"v:a:n:t:",["vedio=", 'audio=', 'number=', 'track='])
    except getopt.GetoptError:
        usage()
        exit()
    audiotrack = 0
    firstnum = 1
    lastnum = 1
    audiofilter = 'copy'
    for o, a in opts:
        if o in ('-v', '--vedio'):
            vediofile = a
        if o in ('-a', '--audio'):
            audiofile = a
        if o in ('-n', '--number'):
            a = a.split("~")
            firstnum = a[0]
            lastnum = a[1]
            if firstnum>lastnum :
                exit("开始数不能大于结束数")
        if o in ('-t', '--track'):
            audiotrack = a
    try:
        audiofile
    except:
        audiofile = vediofile
automux(vediofile,audiofile,firstnum,lastnum,audiotrack,audiofilter)
