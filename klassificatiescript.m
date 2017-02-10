
clear all;

fprintf('Support Vector Classification\n')
fprintf('_____________________________\n')



fig=1;

% Making X and Y
% %*******************
if 1
    N=100;
    sol=classification_dataset(N,'gaussian');
    X=sol{1,1};
    Y=sol{1,2};
    Xtest=sol{1,3};
    Ytest=sol{1,4};
    gam=sol{1,5};
    sigma=sol{1,6};
end
 
% Dimension of the invoer:
 %************************
 [d N]=size(X);%rows and Columns

%visialisation of the input data:
%*******************************
figure(1)
idx=find(Y==1);
idx1=find(Y==-1);
plot(X(1,idx),X(2,idx),'ro',X(1,idx1),X(2,idx1),'b+');  %Inserted to solve the absence of gplotmatrix

% gplotmatrix(X',X',Y)
title('Scatter plot of the input')


% Parameters
%************
% Type of kernels: linear, polynomial, , gaussian_rbf, 
%type='gaussian_rbf';
type='exponential_rbf';

fprintf('Type of kernel %s \n',type)

epsilon=1e-20;


% Penalty factor for missclassification:
C=10;


% For the polynomial kernel :
dp=2;%Grado del polinomio (ver pagina 97)
%gaussianse of exponentiele  RBF kernel:
%sigma=1;

% for the MLP kernel:
scale=0;
offset=0;
% for the B-spline kernel
ds=7;



% parameters:
%************

switch type
case 'linear'
    par=[];%parametros del Kernel
    type_nummer=0;
case 'polynomial'
    % the dimension of the polynomial is given in the variable par
    fprintf('the order is: %d \n',dp)
    par=[dp];%parametros del Kernel(Aqui es el grado del polimonio)
    type_nummer=1;
case 'gaussian_rbf'
    % the sigma value of the rbf is given in par
    % By means of crossvalidation
    fprintf('sigma is:  %d \n',sigma)
    type_nummer=2;
    
    par=[sigma];%parametros del Kernel(Aqui es la desviacion)
    
case 'exponential_rbf'  
    % the sigma value of the rbf is given in par
     fprintf('sigma is:  %d \n',sigma)
    par=[sigma];
    type_nummer=3;
case 'mlp'
    % the w and bias value of the tanh  is given in par
    par=[scale offset];
    type_nummer=4;
case 'Bspline'
    % the order of the B-spline is given in par
    par=[ds];
    type_nummer=6;
case 'Local RBF' %'locale gaussian_rbf' 
    % the sigma value of the rbf is given in par
    % By means of crossvalidation
    fprintf('sigma is:  %d \n',sigma)
    type_nummer=7;
    
    par=[sigma];
end



% training the QP-svm:
% *********************
t=cputime;

oplossing=SVM_TRAINQP(X,Y,epsilon,type_nummer,C,par);

time=cputime-t;
fprintf('The training needed %d',time),fprintf(' seconds.\n');

alpha1=oplossing{1,1};
b1=oplossing{1,2};


% Plotting  training set.
%****************************
if length(X(:,1))==2
    figure(2),subplot(1,2,1)
    SVMplot(X,Y,X,Y,alpha1,b1,40,type_nummer,par,epsilon);
    title('training set');
end

% Classification of the training set:
%************************************
Yclass=sign(fsvmclass(X,Y,type_nummer,epsilon,alpha1,b1,X,par));
misclass=length(find((Yclass+Y)==0));
fprintf('number of misclassified points of the training set: %d (%3.1f%%) \n',misclass,100*misclass/length(Y'));


% Classification of the test set:
%**********************************
if ~(isempty(Xtest))
    if length(X(:,1))==2
        figure(2),subplot(1,2,2),SVMplot(Xtest,Ytest,X,Y,alpha1,b1,40,type_nummer,par,epsilon)
    end 
    
    latent=fsvmclass(X,Y,type_nummer,epsilon,alpha1,b1,Xtest,par);
    
    % ROC curve:
    %************
            p=find(Ytest==-1);
            Yroc=Ytest;
            for i=1:length(p)
                Yroc(p(i))=0;
            end
            figure(3),ROC2(latent,Yroc,1);
            
            
    Yclass=sign(latent);
    misclass=length(find((Yclass+Ytest)==0));
    fprintf('misclassified points of the test set: %d (%3.1f%%) \n',misclass,100*misclass/length(Ytest'));
    title('test set');
end