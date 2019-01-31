from allennlp.predictors.predictor import Predictor
import sys
import os
import glob

def add_entail_label(list):
    max_i= list.index(max(list))

    if max_i == 0:
        return 'yes'
    elif max_i =='1':
        return 'no'
    else :
        return 'unknown'


def main():
    args = sys.argv
    rte_files = glob.glob('{}/{}*'.format(args[1],args[2]))
    predictor = Predictor.from_path("https://s3-us-west-2.amazonaws.com/allennlp/models/decomposable-attention-elmo-2018.02.19.tar.gz")


    for rte in rte_files:
        file_path = rte
        base = os.path.basename(rte)
        output_path = '{}/{}.allen.answer'.format('al_results',base)

        f = open(file_path,'r')
        out = open(output_path,'w')

        list = []
        for l in f:
            list.append(l.rstrip())

        hyp = list[-1]
        list = list[:-1]
        pre = ''.join(list)

        result = predictor.predict(
                hypothesis=hyp,
                premise=pre
                )
        print(hyp)
        print(pre)
        ans = add_entail_label(result['label_probs'])
        print("T_n->C: ",ans)
        print("")
        out.write(ans+'\n')

        list2 = []
        pre = hyp
        for i,s in enumerate(list):

            result = predictor.predict(
                    hypothesis=s,
                    premise=pre
                    )
            print(s)
            print(pre)
            list2.append(s)
            ans = add_entail_label(result['label_probs'])
            print("C->T_{}: ".format(str(i+1)),add_entail_label(result['label_probs']))
            print("")
            out.write(ans+'\n')

        f.close()
        out.close()





if __name__ == '__main__':
    main()
