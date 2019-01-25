﻿using Microblink.Forms.iOS.Recognizers;
using Microblink.Forms.Core.Recognizers;

[assembly: Xamarin.Forms.Dependency(typeof(BruneiIdBackRecognizer))]
namespace Microblink.Forms.iOS.Recognizers
{
    public sealed class BruneiIdBackRecognizer : Recognizer, IBruneiIdBackRecognizer
    {
        MBBruneiIdBackRecognizer nativeRecognizer;

        BruneiIdBackRecognizerResult result;

        public BruneiIdBackRecognizer() : base(new MBBruneiIdBackRecognizer())
        {
            nativeRecognizer = NativeRecognizer as MBBruneiIdBackRecognizer;
            result = new BruneiIdBackRecognizerResult(nativeRecognizer.Result);
        }

        public override IRecognizerResult BaseResult => result;

        public IBruneiIdBackRecognizerResult Result => result;

        
        public bool DetectGlare 
        { 
            get => nativeRecognizer.DetectGlare; 
            set => nativeRecognizer.DetectGlare = value;
        }
        
        public bool ExtractAddress 
        { 
            get => nativeRecognizer.ExtractAddress; 
            set => nativeRecognizer.ExtractAddress = value;
        }
        
        public bool ExtractDateOfIssue 
        { 
            get => nativeRecognizer.ExtractDateOfIssue; 
            set => nativeRecognizer.ExtractDateOfIssue = value;
        }
        
        public bool ExtractRace 
        { 
            get => nativeRecognizer.ExtractRace; 
            set => nativeRecognizer.ExtractRace = value;
        }
        
        public uint FullDocumentImageDpi 
        { 
            get => (uint)nativeRecognizer.FullDocumentImageDpi; 
            set => nativeRecognizer.FullDocumentImageDpi = value;
        }
        
        public IImageExtensionFactors FullDocumentImageExtensionFactors 
        { 
            get => new ImageExtensionFactors(nativeRecognizer.FullDocumentImageExtensionFactors); 
            set => nativeRecognizer.FullDocumentImageExtensionFactors = (value as ImageExtensionFactors).NativeFactors;
        }
        
        public bool ReturnFullDocumentImage 
        { 
            get => nativeRecognizer.ReturnFullDocumentImage; 
            set => nativeRecognizer.ReturnFullDocumentImage = value;
        }
        
    }

    public sealed class BruneiIdBackRecognizerResult : RecognizerResult, IBruneiIdBackRecognizerResult
    {
        MBBruneiIdBackRecognizerResult nativeResult;

        internal BruneiIdBackRecognizerResult(MBBruneiIdBackRecognizerResult nativeResult) : base(nativeResult)
        {
            this.nativeResult = nativeResult;
        }
        public string Address => nativeResult.Address;
        public IDate DateOfIssue => nativeResult.DateOfIssue != null ? new Date(nativeResult.DateOfIssue) : null;
        public Xamarin.Forms.ImageSource FullDocumentImage => nativeResult.FullDocumentImage != null ? Utils.ConvertUIImage(nativeResult.FullDocumentImage.Image) : null;
        public IMrzResult MrzResult => new MrzResult(nativeResult.MrzResult);
        public string Race => nativeResult.Race;
    }
}