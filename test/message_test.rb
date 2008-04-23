# encoding: UTF-8

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

$isi = {}

require 'test/unit'
require 'trunk/isi/lib'
require 'pathname'
require 'trunk/isi/freechat'

module Isi
  module FreeChat
    module Protocol
      module MessageCentre
        class MessageTest < Test::Unit::TestCase
          def setup
            @fingerprint = 'ECAC 373E 790B 985F 57A3  BEDD 4A1A EDA9 87C3 40FA'
            @bb = BuddyBook::BuddyBook.new
            @mc = MessageCentre.new(@bb, @fingerprint)
            @mid = @mc.send :createID
            @args = {
              'int' => 12,
              'mid' => @mid,
              'bid' => @fingerprint,
              'content' => 'EEEELa re ksanthia poy xathikes toson kairo'*23,
              'content2' => 'Η επίσκεψη στο Σπίτι της Διασκέδασης
------------------------------------

Είχα ένα συναίσθημα παρανομίας, βρωμιάς. Έκανα κάτι κακό, το ήξερα. Μου προσέφερε απόλυτη ευτυχία, ανακούφιση, ελευθερία. Κανείς δεν ήταν δυστυχισμένος σε εκείνον τον κόσμο. Κανείς δεν μισούσε κανέναν. Μόνο αγάπη, έρωτας, μέθη, νύχτα.

Υπήρχε κάποιος συνέταιρος, κάποιος γνωστός ή ίσως και όχι τόσο. Ήταν περισσότερο έμπειρος από εμένα και πιθανόν και πιο διεφθαρμένος. Αλλά και πάλι, δεν έφτανε στο επίπεδο του κακού, εκεί που βράζει ο βούρκος και οι αναθυμιάσεις φτάνουν ως εφιάλτες. Απλά είχε χάσει λίγη από την δόξα της νεότητας.

Την οποία και πήγαινε να βρει.

Το δωμάτιο ήταν μονότονο, σχεδόν σαν άδειο νοσοκομείο ή ξενώνας κακής αισθητικής. Οι τοίχοι ήταν μπεζ προς μπλε και από το μοναδικό παράθυρο έμπαινε φως του ίδιου χρώματος. Υπήρχαν δύο κρεβάτια, το ίδιο άσχημα. Χωρίς όμορφα σεντόνια, χωρίς καμπύλα τελειώματα. Ήταν ένα σκέτο στρώμα, άχρωμο, όχι άοσμο αλλά με την γνωστή οσμή χωρίς προσωπικότητα που έχουν τα αντικείμενα που δεν έχουν χρησιμοποιηθεί ακόμα. Όχι ότι ήταν τίποτα τέτοιο. Ίσως να ήταν ένα κακοδιάθετο στρώμα, που δεν ήθελε να συμμετέχει στον κόσμο. Ίσως να διαφωνούσε. Ίσως ήταν θρησκευόμενο ή συντηρητικό. 

Προφανώς για να έρθει κάποιος σε ένα μέρος σαν και αυτό, η διασκέδαση υπάρχει αλλού. Κρύβεται πέρα από το απλοϊκό πέπλο των προταρχικών αισθήσεων.

Μέσα στο άτονο δωμάτιο, επάνω στο απρόσωπο κρεβάτι καθόταν μία ζωηρή άνοιξη. Η ανατολή της ζωής, η πηγή της. Μία σχισμή στο δωμάτιο που είχε σταματήσει ο χρόνος για να ξεχύνονται μέσα του οσμές, χρώματα, περιπέτειες. Η ενέργεια τόσο συγκεντρωμένη που τρομάζει όποιον την κοιτάξει στα μάτια.

Ένα κορίτσι που φοράει ένα μεταξένιο ρούχο, με έντονα σκούρα χρώματα, απεικονίζει λουλούδια και την άβυσσο. Είναι κοντό, φτάνει μέχρι τους γλουτούς της. Ξαπλωμένη με το στήθος στο κρεβάτι και με το ένα γόνατο λυγισμένο προς τα έξω. Κοιμόταν. Ξύπνησε όταν μπήκαμε. Το προσωπό της λείο όπως το φόρεμά της, το βλέμμα της στάζει απόλαυση και ανεξαρτησία. Χαλάρωση και ανέμελη διασκέδαση, στο σπίτι της διασκέδασης.

- "Γειά", μας χαιρέτησε χαμογελώντας. Από μέσα προς τα έξω. Ήταν ευτυχισμένη, το ίδιο ήμασταν και εμείς.

Ο συνέταιρος χάθηκε από το προσκήνιο, έμεινα μόνος μου μαζί της. Ίσως ο άλλος να είχε πάει στο διπλανό κρεβάτι με την άλλη μικρή, την οποία ούτε που είχα παρατηρήσει.

Ξαπλώσαμε μαζί στο κρεβάτι και χάιδευα την πλάτη της με τις άκρες των δακτύλων μου. Γλυστρούσαν ευχάριστα πάνω στο μεταξένιο φόρεμά της. Άγγιζα την άνοιξη, τα λουλούδια, τα κόκαλα, την ενέργεια, την άβυσσο και το δέρμα της μαζί.

Ήμασταν ευτυχισμένοι. Δεν υπήρχε λόγος. Δεν υπήρχε τίποτα. Ίσως για αυτό να μην υπήρχαν προβλήματα. Ήμασταν ευτυχισμένοι, χωρίς προβλήματα. Μόνοι, στο τέλος του χρόνου, στο τέλος των χρωμάτων. Εκεί που τα πάντα σταματούν και αρχίζουν να αποτυπώνονται στο φως σαν σταγόνες χημικές στο χαρτί της φωτογραφίας. Και γίνονται όλα μια φωτογραφία του κόσμου, όπως ήταν σε όλη του την ζωή. Και λιώνουν, εμποτίζουν την πραγματικότητα και μένουν εκεί, λεκέδες από τις πράξεις μας και τις σκέψεις μας, για πάντα, στο τέλος του χρόνου, εκεί που έχουν όλα σταματήσει...

Στεκόταν στα χέρια και στα γόνατά της, προβάλλοντας την μυστική όψη της. Έβαλα δύο δάχτυλα μέσα της και η απαλή σχισμή απ\' όπου διέρρεε η ψυχή της για να βγει ελεύθερη και να βρει αυτό που ψάχνει άνοιξε στα δύο. Εμφάνισε την εσωτερική της απαλότητα, ζωηρή και κοκκινοπή. Γύρισε το κεφάλι της προς τα εμένα και μου χαμογέλασε. Κούνισε το σώμα της ελεφρά εμπρώς και πίσω, σαν να προσπαθούσε να χαιδέψει τα δάχτυλά μου εκεί που βρισκόταν. Τράβηξα τα δάχτυλα μου και ζωγράφισα στο κρεβάτι.

Καταλήξαμε αγκαλιασμένοι να μιλάμε. Ήμασταν ευτυχισμένοι γιατί δεν υπήρχαν κανόνες. Δεν υπήρχαν κανόνες γιατί δεν υπήρχε κακία. Μόνο έρωτας. Και πινέλα.

Και τότε χτύπησε η πόρτα. Σηκώθηκα αμέσως και προσπάθησα να φύγω πριν με δει αυτός που ήρθε. Αλλά με είδε. Κρατούσε κάτι χαρτιά. Με ήξερε. Τώρα ήξερε επίσης ότι είχα έρθει σε αυτό το μέρος. Ο χρόνος επανήλθε. Ο κόσμος μας έφτασε. Μας έπιασε.

Αγχώθηκα. Ήξερε ότι είχα πάει εκεί. Κρατούσε κάτι έγγραφα. Τον προσπέρασα και προσπάθησα να φύγω. Πήγα στην αίθουσα με τους υπολογιστές. Ήρθε και κάθησε δίπλα μου. Μου έδειξα τα έγγραφα που κρατούσε. Κάποιος είχε δαγκώσε και έσκισε ένα μέρος τους. Φαινόταν τα ίχνη από τα δόντια. Μάλλον ήμουν εγώ. Εγώ και το άγχος.

Του ζήτησα συγνώμη, του είπα ότι θα αναπαράγω το χαμένο κομμάτι από τα έγγραφα στον υπολογιστή. Είπε εντάξει και έφυγε. Άνοιξα το πρόγραμμα: ήταν τεράστιο, η οθόνη ήταν τεράστια, οι επιλογές και τα εργαλεία άπειρα. Ήταν αργά, πολύ αργά, νύσταζα, τα μάτια μου θολώναν. Προσπάθησα να βρω τί πρέπει να κάνω μέσα απο τις επιλογές, το βρήκα. Ξεκίνησα να γράφω, στην τεράστια οθόνη. Μόλις ξεκίνησα ήρθε πάλι μέσα. Με ρώτησε πού βρισκόμουν, του έδειξα την τεράστια οθόνη. Κατάλαβε ότι δεν πρόκειται να κάνω τίποτα απόψε και μου είπε ότι δεν πειράζει. Σκέφτηκα ότι μάλλον δεν θα έλεγε σε κανέναν ότι είχα πάει εκεί. Η νύστα μου έφυγε, σηκώθηκα και πήγα πάλι στο δωμάτιο.

Ήταν αλλιώς. Ήταν το ίδιο, αλλά ήταν αλλιώς. Ο χρόνος ήταν εκεί, ο κόσμος ήταν εκεί. Τα πράγματα ήταν αληθινά, ο αισθήματα έλειπαν. Η άνοιξη καθόταν ακόμα πάνω στο κρεβάτι. Κάθησα και εγώ, ήρθε και με αγκάλιασε. Όμως δεν ήμασταν πλέον μαζί. Δεν ήμασταν πλέον ευτυχισμένοι. Ο κόσμος μας έφτασε και τα προβλήματα ήταν εδώ. Τα αισθήματα και οι αισθήσεις χάθηκαν, τρόμαξαν, κρύφτηκαν. Τις χτύπησαν τα χαρτιά και οι κανόνες.

Στο πίσω μέρος απο τα παπούτσια μου (και του συνεταίρου) άρχισαν να αναβοσβήνουν μικρά κόκκινα φωτάκια, αγχομένα, συνοδευόμενα από τον κατάλληλο αγχομένο ήχο του κινδύνου. "Μπιιμπιιμπιιμπιι...".

Κοιταχτήκαμε τρομαγμένοι με τον συνέταιρο επειδή ξέραμε τί συμβαίνει. Τρέξαμε και οι δύο στα παπούτσια μας και προσπαθήσαμε να τα φορέσουμε όσο πιο γρήγορα γινόταν. Λιγότερο από τρία δευτερόλεπτα απέμεναν. Η άνοιξη χανόταν πίσω μου αλλά δεν έμενε μυαλό για να την αναλογιστεί. Τί να συλλογιστεί πρώτο κανείς; Την άνοιξη που χάνετε ή την πιχτή αδράνεια που θα έρθει;

- "Πρέπει να μετακινηθείς πιο εκεί, αλλιώς θα καταλήξεις σε τοίχο!", μου φώναξε ο συνέταιρος τρομοκρατημένος.

Έκανα την καλύτερη υπόθεση που μπορούσα, πήδηξα μισό μέτρο στο πλάι, και τα "μπιι" σταμάτησαν. Το δωμάτιο χάθηκε, η άνοιξη εξαφανίστηκε. Τηλεμεταφερθήκαμε πίσω στον δικό μας χρόνο. Αλλά ο συνέταιρος είχε δίκιο. Κατέληξα σε τοίχο. 

Το μαύρο δεν έφυγε, το δωμάτιο δεν επανήλθε στην παλαιότερη μορφή. Πανικός. Ήμουν μέσα στον τοίχο. Πέθανα. Προσπαθούσα να σκεφτώ με ποιόν τρόπο μπορεί να πάει κάποιος πίσω εκεί που ήμασταν, στο τέλος του χρόνου, και να με σταματήσει, να με μετακινήσει, να ξεκινήσω από κάπου αλλού. Δεν ήθελα να πεθάνω. Δεν υπήρχε τρόπος. Ο συνέταιρος μάλλον πέθανε και αυτός. Κανείς δεν μπορούσε να πάει πίσω.

Και έτσι τελείοσε η επίσκεψή μου στο σπίτι της διασκέδασης, το οποίο βρίσκεται πέρα από τον κόσμο, αποκολημένο από την πραγματικότητα, έξω από τον χρόνο. Μακριά, όσο πιο μακριά γίνεται από τον κόσμο, εκεί που τα όνειρα γεννιούνται και μεγαλόνουν, αλλά δεν πεθαίνουν, εκεί που οι αισθήσεις επιπλέουν στον αέρα και ο αέρας επιπλέει πάνω στα όνειρα. Εκεί που δεν υπάρχει κακία γιατί δεν υπάρχει θάνατος, εκεί που δεν υπάρχει πόνος και είναι όλα όμορφα. Αγάπη, έρωτας, μέθη, νύχτα.

'
            }
            @restrictions = {
              'mid' => String, 'bid' => String,
              'content' => String, 'content2' => String,
              'int' => Integer,
            }
            @type = 12
            @message = Message.new @type, @mid, @args, @restrictions
          end
          
          def test_serialise
            sdata = @message.serialise
            p sdata, sdata.length
            type, mid, args= Message::deserialise(sdata)
            type = Integer::from_bytes(type.bytes.to_a)
            args['int'] = Integer::from_bytes(args['int'].bytes.to_a)
            assert_equal @type, type
            assert_equal @mid, mid
            assert_equal @args, args
          end
          
          def test_argument_restrictions
            assert_raise(MessageArgumentNameException) {
              @message['bollock'] = nil
            }
            assert_raise(MessageArgumentTypeException) {
              @message['bid'] = 12
            }
          end
          
        end
      end
    end
  end
end
