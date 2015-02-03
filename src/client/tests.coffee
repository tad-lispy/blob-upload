# Test suit to be ran in browser
{ expect } = chai

describe 'XHR FormData API', ->

  it 'can send simple object', (done) ->
    data =
      name: 'Katiusza'
      age : '4' # Everything is converted to string by multipart form data enc.

    form = new FormData
    for key, value of data
      form.append key, value

    req = new XMLHttpRequest

    # Response type must be set after request is opened.
    # Otherwise IE will spit in your eye.
    # See: https://connect.microsoft.com/IE/feedback/details/795580
    req.open 'post', '/'
    req.responseType = 'json'
    req.send form
    req.onload = ->
      expect(@status).to.eql 200
      expect(@responseType).to.eql 'json'
      expect(@response.body).to.eql data
      do done

  it 'can send object with nested array', (done) ->
    data =
      name: 'Katiusza'
      age : '4'
      toys: [
        'sznurek'
        'jajo'
        'korek'
      ]

    form = new FormData
    for key, value of data
      if _.isArray value then for element in value
        form.append key, element
      else
        form.append key, value

    req = new XMLHttpRequest
    req.open 'post', '/'
    req.responseType = 'json'
    req.send form
    req.onload = ->
      expect(@status).to.eql 200
      expect(@responseType).to.eql 'json'
      expect(@response.body).to.eql data
      do done

  it 'can send blobs as files', (done) ->
    data =
      name: 'Katiusza'
      age : '4'
      toys: [
        'sznurek'
        'jajo'
        'korek'
      ]
      anthem : new Blob [
        'Bardzo mała jest nasza Katiucha'
        'Mierzona od ucha do ucha.'
        'Natomiast gdy jest mierzona'
        'Od ucha do ogona'
        'To nadal jest nieduża.'
        'Ot, cała nasza katiusza!'
      ], type: 'text/plain', fileName: 'anthem.txt'

    form = new FormData
    for key, value of data
      if _.isArray value then for element in value
        form.append key, element
      else
        form.append key, value

    req = new XMLHttpRequest
    req.open 'post', '/'
    req.responseType = 'json'
    req.send form
    req.onload = ->
      expect(@status).to.eql 200
      expect(@responseType).to.eql 'json'
      expect(@response.body).to.eql _.omit data, ['anthem']
      expect(@response.files).to
        .be.an 'object'
        .and.have.property 'anthem'

      expect(@response.files.anthem).to
        .be.an 'object'
        .and.have.property 'size', data.anthem.size

      do done

describe 'jQuery + FormData', ->
  # See: https://developer.mozilla.org/en-US/docs/Web/Guide/Using_FormData_Objects
  it 'can send simple FormData object', (done) ->
    data =
      name: 'Katiusza'
      age : '4' # Everything is converted to string by multipart form data enc.

    form = new FormData
    for key, value of data
      form.append key, value

    jQuery
      .ajax
        url         : '/'
        data        : form
        type        : 'POST'
        processData : no
        contentType : no
      .done (res) ->
        expect(res).to
          .be.an 'object'
          .and.have.keys [
            'body'
            'files'
          ]
        expect(res.body).to
          .be.an 'object'
          .and.have.keys [
            'name'
            'age'
          ]

        do done

  it 'can send blobs as files', (done) ->
    data =
      name: 'George'
      age : '4'
      toys: [
        'sznurek'
        'kocyk'
        'pudło'
      ]
      # Cool cats here: https://user.xmission.com/~emailbox/ascii_cats.htm
      image: new Blob """
                      __..--''``---....___   _..._    __
            /// //_.-'    .-/";  `        ``<._  ``.''_ `. / // /
           ///_.-' _..--.'_    \                    `( ) ) // //
           / (_..-' // (< _     ;_..__               ; `' / ///
            / // // //  `-._,_)' // / ``--...____..-' /// / //
        Felix Lee
      """.split("\n"),
        type: 'text/plain'
        fileName: 'George.txt'

    form = new FormData
    for key, value of data
      if _.isArray value then for element in value
        form.append key, element
      else
        form.append key, value

    jQuery
      .ajax
        url         : '/'
        data        : form
        type        : 'POST'
        processData : no
        contentType : no
      .done (res) ->
        expect(res).to
          .be.an 'object'
          .and.have.keys [
            'body'
            'files'
          ]
        expect(res.body).to
          .be.an 'object'
          .and.have.keys [
            'name'
            'age'
            'toys'
          ]

        expect(res.files).to
          .be.an 'object'
          .and.have.property 'image'

        expect(res.files.image).to
          .be.an 'object'
          .and.have.property 'size', data.image.size

        do done

  it 'can use data from html form', (done) ->
    form = new FormData $('form')[0]

    # More cool cats here: http://www.asciiworld.com/-Cats-.html
    image = """
      |                      ,/\,,,,/\,.
      |                     =          =,
      |                    =` '<Q> <Q>'  =,
      |         ,=~~~~~~~~~`=     Y    =,`;,
      |       ,='            // :-^-; \\  `;
      |     ,='       `      ,,,,.'       :;
      |     ;,        '`          ':      `;
      |     ;`         ;',          ::,   ;;
      |     '\`   `,`';'`'`;`'`;';,  `; ':;
      |      '\`  '`\;~~~;/~~;~;/\`,  ';'`;
      |      /#\`  `'\#############)),';~#\
      |     /##\`  '`\\############))_;####\
      |    |###\`'`'\\MMMMMMMMMMMMMMMMMMMMMM|
      |    |NNNN\`'`\\NNNNNNNNNNNNNNNNNNNNNN|
      |    |YYYYY`\\\`YYYYYYYYYYYYYYYYYYYYYY|
      |    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      |    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      |    ::::::::::::::::::::::::::::::::::
      |----''''''''''''''''''''''''''''''''''----
    """

    blob = new Blob image.split("\n"),
      type    : 'text/plain'
      filename: 'Scoobie.txt'

    form.append 'image', blob

    jQuery
      .ajax
        url         : '/'
        data        : form
        type        : 'POST'
        processData : no
        contentType : no
      .done (res) ->
        expect(res).to
          .be.an 'object'
          .and.have.keys [
            'body'
            'files'
          ]
        expect(res.body).to
          .be.an 'object'
          .and.have.keys [
            'name'
            'weight'
          ]

        expect(res.files).to
          .be.an 'object'
          .and.have.property 'image'

        expect(res.files.image).to
          .be.an 'object'
          .and.have.property 'size', blob.size

        do done
