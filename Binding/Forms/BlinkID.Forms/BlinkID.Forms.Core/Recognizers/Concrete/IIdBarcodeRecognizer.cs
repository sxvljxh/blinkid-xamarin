﻿namespace Microblink.Forms.Core.Recognizers
{
    /// <summary>
    /// The ID Barcode Recognizer is used for scanning ID Barcode.
    /// </summary>
    public interface IIdBarcodeRecognizer : IRecognizer
    {
        

        /// <summary>
        /// Gets the result.
        /// </summary>
        IIdBarcodeRecognizerResult Result { get; }
    }

    /// <summary>
    /// Result object for IIdBarcodeRecognizer.
    /// </summary>
    public interface IIdBarcodeRecognizerResult : IRecognizerResult {
        
        /// <summary>
        /// THe additional address information of the document owner. 
        /// </summary>
        string AdditionalAddressInformation { get; }
        
        /// <summary>
        /// The additional name information of the document owner. 
        /// </summary>
        string AdditionalNameInformation { get; }
        
        /// <summary>
        /// The address of the document owner. 
        /// </summary>
        string Address { get; }
        
        /// <summary>
        /// The current age of the document owner in years. It is calculated difference
        /// between now and date of birth. Now is current time on the device.
        /// @return current age of the document owner in years or -1 if date of birth is unknown. 
        /// </summary>
        int Age { get; }
        
        /// <summary>
        /// Type of the barcode scanned
        /// 
        ///  @return Type of the barcode 
        /// </summary>
        BarcodeType BarcodeType { get; }
        
        /// <summary>
        /// The date of birth of the document owner. 
        /// </summary>
        IDate DateOfBirth { get; }
        
        /// <summary>
        /// The date of expiry of the document. 
        /// </summary>
        IDate DateOfExpiry { get; }
        
        /// <summary>
        /// The date of issue of the document. 
        /// </summary>
        IDate DateOfIssue { get; }
        
        /// <summary>
        /// The additional number of the document. 
        /// </summary>
        string DocumentAdditionalNumber { get; }
        
        /// <summary>
        /// The document number. 
        /// </summary>
        string DocumentNumber { get; }
        
        /// <summary>
        /// The document type deduced from the recognized barcode
        /// 
        ///  @return Type of the document 
        /// </summary>
        IdBarcodeDocumentType DocumentType { get; }
        
        /// <summary>
        /// The employer of the document owner. 
        /// </summary>
        string Employer { get; }
        
        /// <summary>
        /// The first name of the document owner. 
        /// </summary>
        string FirstName { get; }
        
        /// <summary>
        /// The full name of the document owner. 
        /// </summary>
        string FullName { get; }
        
        /// <summary>
        /// The issuing authority of the document. 
        /// </summary>
        string IssuingAuthority { get; }
        
        /// <summary>
        /// The last name of the document owner. 
        /// </summary>
        string LastName { get; }
        
        /// <summary>
        /// The marital status of the document owner. 
        /// </summary>
        string MaritalStatus { get; }
        
        /// <summary>
        /// The nationality of the documet owner. 
        /// </summary>
        string Nationality { get; }
        
        /// <summary>
        /// The personal identification number. 
        /// </summary>
        string PersonalIdNumber { get; }
        
        /// <summary>
        /// The place of birth of the document owner. 
        /// </summary>
        string PlaceOfBirth { get; }
        
        /// <summary>
        /// The profession of the document owner. 
        /// </summary>
        string Profession { get; }
        
        /// <summary>
        /// The race of the document owner. 
        /// </summary>
        string Race { get; }
        
        /// <summary>
        /// Byte array with result of the scan 
        /// </summary>
        byte[] RawData { get; }
        
        /// <summary>
        /// The religion of the document owner. 
        /// </summary>
        string Religion { get; }
        
        /// <summary>
        /// The residential stauts of the document owner. 
        /// </summary>
        string ResidentialStatus { get; }
        
        /// <summary>
        /// The sex of the document owner. 
        /// </summary>
        string Sex { get; }
        
        /// <summary>
        /// Retrieves string content of scanned data 
        /// </summary>
        string StringData { get; }
        
        /// <summary>
        /// Flag indicating uncertain scanning data
        /// E.g obtained from damaged barcode. 
        /// </summary>
        bool Uncertain { get; }
        
    }
}