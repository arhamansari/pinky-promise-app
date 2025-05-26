from .models import Doctor, Patient, ChatRoom
import uuid
from django.db import transaction

class PatientDoctorAssignmentService:
    @staticmethod
    def assign_patient_to_doctor(patient):
        available_doctors = Doctor.objects.filter(
            is_available=True,
            current_patient_count__lt=models.F('max_patients')
        ).order_by('current_patient_count')
        
        if available_doctors.exists():
            doctor = available_doctors.first()
            with transaction.atomic():
                patient.assigned_doctor = doctor
                patient.assignment_status = 'assigned'
                patient.save()
                
                doctor.current_patient_count += 1
                doctor.save()
                
                # Create chat room
                room_id = f"chat_{patient.id}_{doctor.id}_{uuid.uuid4().hex[:8]}"
                chat_room = ChatRoom.objects.create(
                    patient=patient,
                    doctor=doctor,
                    room_id=room_id
                )
                return chat_room
        return None
