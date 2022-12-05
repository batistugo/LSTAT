import matplotlib.pyplot as plt
import seaborn as sns

def lines_plot(df, stations, freq = 'M', figsize = (20,5), tittle = ''):
    ls = ['date_time'] + stations
    temp = df[ls]
    temp.index = temp.date_time
    temp = temp.resample(freq).mean()
    temp.reset_index(inplace=True)
    plt.figure(figsize = figsize)
    _ = sns.lineplot(x = temp['date_time'],y = temp[stations[0]]).set_title(tittle,fontsize=20)
    for i in stations[1:]:
        _ = sns.lineplot(x = temp['date_time'],y = temp[i])
        
def columnX(code): 
    return f'{code} - temperatura maxima na hora ant. (aut) (°c)'